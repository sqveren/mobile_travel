import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/bloc/travel_planner_bloc.dart';
import 'package:my_app/data/travel_repository.dart';
import 'package:my_app/models/travel_models.dart';

void main() {
  group('TravelPlannerBloc', () {
    test('builds prioritized plan and resets visited places on success', () async {
      // Базовий happy path:
      // план успішно генерується, місця сортуються за пріоритетом,
      // а visited-стан очищається для нового маршруту.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{'Kyiv, Ukraine': _samplePlaces},
        ),
      );
      final emittedStates = <TravelPlannerState>[];
      final subscription = bloc.stream.listen(emittedStates.add);

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 2,
          pace: 'standard',
          travelType: 'cultural',
        ),
      );

      await _flushBloc();

      expect(emittedStates, hasLength(2));
      expect(emittedStates.first.status, TravelPlannerStatus.loading);
      expect(bloc.state.status, TravelPlannerStatus.success);
      expect(bloc.state.visitedPlaces, isEmpty);
      expect(bloc.state.plan, hasLength(2));
      expect(
        bloc.state.plan.first.places.map((place) => place.name).toList(),
        <String>['Opera House', 'Old Fortress', 'Riverside Walk'],
      );
      expect(bloc.state.plan.first.places.first.id, 'opera-1-1');
      expect(bloc.state.plan.last.places.first.id, 'arcade-2-1');

      await subscription.cancel();
      await bloc.close();
    });

    test('clamps days to seven and adjusts places per day by pace', () async {
      // Перевіряємо бізнес-правила генерації:
      // days обмежується до 7, а active pace дає 4 місця на день.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{'Kyiv, Ukraine': _samplePlaces},
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 10,
          pace: 'active',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(bloc.state.status, TravelPlannerStatus.success);
      expect(bloc.state.plan, hasLength(7));
      expect(
        bloc.state.plan.every((dayPlan) => dayPlan.places.length == 4),
        isTrue,
      );

      await bloc.close();
    });

    test('emits failure when repository throws during generation', () async {
      // Якщо джерело даних падає, Bloc повинен віддати failure
      // і зберегти тип помилки для UI.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesError: StateError('database unavailable'),
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 3,
          pace: 'calm',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(bloc.state.status, TravelPlannerStatus.failure);
      expect(bloc.state.errorType, TravelPlannerErrorType.generatePlan);

      await bloc.close();
    });

    test('toggles visited place ids on and off', () async {
      // Простий тест перемикача:
      // повторне натискання має прибирати id зі списку visited.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{'Kyiv, Ukraine': _samplePlaces},
        ),
      );

      bloc.add(const TravelPlaceVisitedToggled('opera-1-1'));
      await _flushBloc();
      expect(bloc.state.visitedPlaces, <String>{'opera-1-1'});

      bloc.add(const TravelPlaceVisitedToggled('opera-1-1'));
      await _flushBloc();
      expect(bloc.state.visitedPlaces, isEmpty);

      await bloc.close();
    });

    test('uses default pace when unknown value is provided', () async {
      // Захист від невалідного pace:
      // невідоме значення має працювати як standard.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{'Kyiv, Ukraine': _samplePlaces},
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 1,
          pace: 'turbo',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(bloc.state.status, TravelPlannerStatus.success);
      expect(bloc.state.plan.single.places, hasLength(3));

      await bloc.close();
    });

    test('clamps days below one to a single day', () async {
      // Крайній випадок по кількості днів:
      // якщо передати 0, алгоритм все одно має зробити 1 день.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{'Kyiv, Ukraine': _samplePlaces},
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 0,
          pace: 'calm',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(bloc.state.status, TravelPlannerStatus.success);
      expect(bloc.state.plan, hasLength(1));
      expect(bloc.state.plan.single.places, hasLength(2));

      await bloc.close();
    });

    test('returns empty plan when repository has no places', () async {
      // Простіше за все перевірити порожні дані окремо:
      // success зберігається, але план порожній.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{'Kyiv, Ukraine': const <Place>[]},
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 3,
          pace: 'standard',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(bloc.state.status, TravelPlannerStatus.success);
      expect(bloc.state.plan, isEmpty);

      await bloc.close();
    });

    test('prefers entertainment categories for entertainment travel type', () async {
      // Середній сценарій на правильну пріоритезацію категорій.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{
            'Kyiv, Ukraine': <Place>[
              _place(
                id: 'games',
                name: 'Game Center',
                importance: Importance.high,
                category: 'Entertainment',
              ),
              _place(
                id: 'food',
                name: 'Food Hall',
                importance: Importance.high,
                category: 'Food',
              ),
              _place(
                id: 'river',
                name: 'River View',
                importance: Importance.high,
                category: 'Scenic',
              ),
            ],
          },
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 1,
          pace: 'standard',
          travelType: 'entertainment',
        ),
      );

      await _flushBloc();

      expect(
        bloc.state.plan.single.places.map((place) => place.name).toList(),
        <String>['Game Center', 'Food Hall', 'River View'],
      );

      await bloc.close();
    });

    test('falls back to alphabetical order for equally ranked places', () async {
      // Якщо місця однакові за importance і category,
      // порядок має визначатись назвою.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{
            'Kyiv, Ukraine': <Place>[
              _place(
                id: 'b',
                name: 'Zoo Square',
                importance: Importance.medium,
                category: 'Nature',
              ),
              _place(
                id: 'a',
                name: 'Botanical Garden',
                importance: Importance.medium,
                category: 'Nature',
              ),
              _place(
                id: 'c',
                name: 'Central Park',
                importance: Importance.medium,
                category: 'Nature',
              ),
            ],
          },
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 1,
          pace: 'standard',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(
        bloc.state.plan.single.places.map((place) => place.name).toList(),
        <String>['Botanical Garden', 'Central Park', 'Zoo Square'],
      );

      await bloc.close();
    });

    test('cycles through templates when more places are needed than available', () async {
      // Трохи важчий кейс:
      // шаблони мають циклічно повторюватись, але з новими унікальними id.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{
            'Kyiv, Ukraine': <Place>[
              _place(id: 'a', name: 'A', importance: Importance.high),
              _place(id: 'b', name: 'B', importance: Importance.medium),
            ],
          },
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 2,
          pace: 'active',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(bloc.state.plan, hasLength(2));
      expect(bloc.state.plan.first.places, hasLength(4));
      expect(
        bloc.state.plan.first.places.map((place) => place.name).toList(),
        <String>['A', 'B', 'A', 'B'],
      );
      expect(
        bloc.state.plan.first.places.map((place) => place.id).toSet(),
        hasLength(4),
      );

      await bloc.close();
    });

    test('clears previous error after successful retry', () async {
      // Після нового успішного запиту попередня помилка має зникати.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCitySequence: <Object>[
            StateError('temporary failure'),
            <Place>[_place(id: 'opera', name: 'Opera House')],
          ],
        ),
      );

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 1,
          pace: 'standard',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();
      expect(bloc.state.status, TravelPlannerStatus.failure);
      expect(bloc.state.errorType, TravelPlannerErrorType.generatePlan);

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 1,
          pace: 'standard',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(bloc.state.status, TravelPlannerStatus.success);
      expect(bloc.state.errorType, isNull);

      await bloc.close();
    });

    test('resets visited places when a new plan is generated', () async {
      // Важлива умова: новий маршрут починається з чистого visited-стану.
      final bloc = TravelPlannerBloc(
        repository: _FakeTravelRepository(
          placesByCity: <String, List<Place>>{'Kyiv, Ukraine': _samplePlaces},
        ),
      );

      bloc.add(const TravelPlaceVisitedToggled('old-place'));
      await _flushBloc();
      expect(bloc.state.visitedPlaces, <String>{'old-place'});

      bloc.add(
        const TravelPlanRequested(
          city: 'Kyiv, Ukraine',
          days: 1,
          pace: 'standard',
          travelType: 'mixed',
        ),
      );

      await _flushBloc();

      expect(bloc.state.status, TravelPlannerStatus.success);
      expect(bloc.state.visitedPlaces, isEmpty);

      await bloc.close();
    });
  });
}

Future<void> _flushBloc() async {
  // Даємо Bloc час обробити подію і віддати новий стан у стрім.
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

// Набір тестових місць із різними importance і category,
// щоб перевіряти порядок сортування та розподіл по днях.
const List<Place> _samplePlaces = <Place>[
  Place(
    id: 'food',
    name: 'Old Fortress',
    importance: Importance.high,
    category: 'Food',
    description: 'Traditional cuisine inside a historic fort.',
    lat: 50.4501,
    lng: 30.5234,
  ),
  Place(
    id: 'opera',
    name: 'Opera House',
    importance: Importance.high,
    category: 'Culture',
    description: 'A landmark opera theater in the city center.',
    lat: 50.4547,
    lng: 30.5166,
  ),
  Place(
    id: 'riverside',
    name: 'Riverside Walk',
    importance: Importance.medium,
    category: 'Scenic',
    description: 'Popular evening promenade with river views.',
    lat: 50.4470,
    lng: 30.5280,
  ),
  Place(
    id: 'arcade',
    name: 'Arcade Hub',
    importance: Importance.low,
    category: 'Entertainment',
    description: 'Indoor games and evening activities.',
    lat: 50.4420,
    lng: 30.5200,
  ),
];

class _FakeTravelRepository implements TravelRepository {
  // Мінімальний фейковий репозиторій для unit-тестів:
  // повертає заготовлені дані або кидає помилку.
  _FakeTravelRepository({
    this.cities = const <String>['Kyiv, Ukraine'],
    this.placesByCity = const <String, List<Place>>{},
    List<Object>? placesByCitySequence,
    this.citiesError,
    this.placesError,
  }) : _placesByCitySequence =
           placesByCitySequence == null
               ? null
               : List<Object>.from(placesByCitySequence);

  final List<String> cities;
  final Map<String, List<Place>> placesByCity;
  final List<Object>? _placesByCitySequence;
  final Object? citiesError;
  final Object? placesError;

  @override
  Future<List<String>> fetchCities() async {
    if (citiesError != null) {
      throw citiesError!;
    }
    return cities;
  }

  @override
  Future<List<Place>> fetchPlacesForCity(String city) async {
    if (placesError != null) {
      throw placesError!;
    }
    if (_placesByCitySequence != null) {
      if (_placesByCitySequence.isEmpty) {
        throw StateError('No more fake place responses configured.');
      }

      final next = _placesByCitySequence.removeAt(0);
      if (next is Exception || next is Error) {
        throw next;
      }

      return next as List<Place>;
    }

    return placesByCity[city] ?? const <Place>[];
  }
}

Place _place({
  required String id,
  required String name,
  Importance importance = Importance.high,
  String category = 'Culture',
}) {
  return Place(
    id: id,
    name: name,
    importance: importance,
    category: category,
    description: 'Test place description.',
    lat: 50.4501,
    lng: 30.5234,
  );
}
