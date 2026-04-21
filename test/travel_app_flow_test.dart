import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/data/travel_repository.dart';
import 'package:my_app/l10n/app_localizations.dart';
import 'package:my_app/main.dart';
import 'package:my_app/models/travel_models.dart';

void main() {
  group('Travel app flow', () {
    testWidgets('generate button stays disabled until form is complete', (
      tester,
    ) async {
      // Простий сценарій валідації:
      // кнопка не повинна активуватись, поки не вибрані pace і type.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          <String>['Kyiv, Ukraine', 'Lviv, Ukraine'],
        ],
        placesResponses: <Object>[
          <Place>[_place(id: 'gate', name: 'Golden Gate')],
        ],
      );

      await _pumpApp(tester, repository: repository);

      expect(_generateButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();
      expect(_generateButton(tester).onPressed, isNull);

      await tester.ensureVisible(find.text('Calm'));
      await tester.tap(find.text('Calm'));
      await tester.pump();
      expect(_generateButton(tester).onPressed, isNull);

      await tester.ensureVisible(find.text('Mixed'));
      await tester.tap(find.text('Mixed'));
      await tester.pump();

      expect(_generateButton(tester).onPressed, isNotNull);
    });

    testWidgets('generates a plan, opens details, and updates visited state', (
      tester,
    ) async {
      // Повний користувацький сценарій:
      // від форми до деталей місця і назад з оновленим visited-станом.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          <String>['Kyiv, Ukraine', 'Lviv, Ukraine'],
        ],
        placesResponses: <Object>[
          <Place>[
            _place(
              id: 'gate',
              name: 'Golden Gate',
              importance: Importance.high,
              category: 'Culture',
            ),
            _place(
              id: 'square',
              name: 'Market Square',
              importance: Importance.medium,
              category: 'City Walk',
            ),
            _place(
              id: 'museum',
              name: 'City Museum',
              importance: Importance.medium,
              category: 'Art',
            ),
          ],
        ],
      );

      await _pumpApp(tester, repository: repository);

      final generateButton = _generateButton(tester);
      expect(generateButton.onPressed, isNull);

      await tester.ensureVisible(find.text('Calm'));
      await tester.tap(find.text('Calm'));
      await tester.pump();
      await tester.ensureVisible(find.text('Mixed'));
      await tester.tap(find.text('Mixed'));
      await tester.pump();

      expect(_generateButton(tester).onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Generate Plan'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Your Travel Plan'), findsOneWidget);
      expect(find.text('Golden Gate'), findsWidgets);
      expect(find.text('Visited 0 of 6 places'), findsOneWidget);

      await tester.tap(find.text('Golden Gate').first);
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
      expect(
        find.text('A must-see stop in the historic center.'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Mark as Visited'));
      await tester.pumpAndSettle();

      expect(find.text('Visited'), findsOneWidget);
      expect(find.text('You have visited this place'), findsOneWidget);

      await tester.tap(find.text('Back to Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Visited 1 of 6 places'), findsOneWidget);
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox).first).value,
        isTrue,
      );
    });

    testWidgets('shows empty-state plan when generation returns no places', (
      tester,
    ) async {
      // Середній сценарій без результатів:
      // після успішної генерації має відкритись порожній план.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          <String>['Kyiv, Ukraine'],
        ],
        placesResponses: <Object>[
          const <Place>[],
        ],
      );

      await _pumpApp(tester, repository: repository);

      await tester.ensureVisible(find.text('Calm'));
      await tester.tap(find.text('Calm'));
      await tester.pump();
      await tester.ensureVisible(find.text('Mixed'));
      await tester.tap(find.text('Mixed'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Generate Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Your Travel Plan'), findsOneWidget);
      expect(
        find.text('No plan yet. Go to Generate and create your trip.'),
        findsOneWidget,
      );
    });

    testWidgets('opens map tab from bottom navigation', (tester) async {
      // Простий навігаційний тест:
      // нижня панель повинна перемикати користувача на вкладку карти.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          <String>['Kyiv, Ukraine'],
        ],
        placesResponses: <Object>[
          <Place>[_place(id: 'gate', name: 'Golden Gate')],
        ],
      );

      await _pumpApp(tester, repository: repository);

      await tester.tap(find.text('Map'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Live Map'), findsOneWidget);
    });

    testWidgets('shows generate error message when plan building fails', (
      tester,
    ) async {
      // Перевіряємо, що помилка з Bloc повертається на головний екран.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          <String>['Kyiv, Ukraine'],
        ],
        placesResponses: <Object>[
          StateError('db error'),
        ],
      );

      await _pumpApp(tester, repository: repository);

      await tester.ensureVisible(find.text('Calm'));
      await tester.tap(find.text('Calm'));
      await tester.pump();
      await tester.ensureVisible(find.text('Mixed'));
      await tester.tap(find.text('Mixed'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Generate Plan'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Could not generate the plan from PostgreSQL. Check the data types and database connection.',
        ),
        findsOneWidget,
      );
      expect(find.text('Generate Plan'), findsOneWidget);
    });

    testWidgets('shows loading indicator while generating a plan', (
      tester,
    ) async {
      // Трохи важчий асинхронний кейс:
      // під час очікування кнопка має показувати progress indicator.
      final repository = _DelayedTravelRepository(
        cities: const <String>['Kyiv, Ukraine'],
        places: <Place>[_place(id: 'gate', name: 'Golden Gate')],
        delay: const Duration(milliseconds: 200),
      );

      await _pumpApp(tester, repository: repository);

      await tester.ensureVisible(find.text('Calm'));
      await tester.tap(find.text('Calm'));
      await tester.pump();
      await tester.ensureVisible(find.text('Mixed'));
      await tester.tap(find.text('Mixed'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Generate Plan'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('Your Travel Plan'), findsOneWidget);
    });

    testWidgets('updates summary when visited checkbox is toggled in plan', (
      tester,
    ) async {
      // Середній сценарій на інтеракцію в самому плані без переходу в details.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          <String>['Kyiv, Ukraine'],
        ],
        placesResponses: <Object>[
          <Place>[
            _place(id: 'gate', name: 'Golden Gate'),
            _place(id: 'square', name: 'Market Square'),
            _place(id: 'museum', name: 'City Museum'),
          ],
        ],
      );

      await _pumpApp(tester, repository: repository);

      await tester.ensureVisible(find.text('Calm'));
      await tester.tap(find.text('Calm'));
      await tester.pump();
      await tester.ensureVisible(find.text('Mixed'));
      await tester.tap(find.text('Mixed'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Generate Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Visited 0 of 6 places'), findsOneWidget);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(find.text('Visited 1 of 6 places'), findsOneWidget);
    });

    testWidgets('keeps place details action text in sync with visited state', (
      tester,
    ) async {
      // Перевіряємо дрібну, але корисну поведінку:
      // кнопка у деталях має переключати текст після натискання.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          <String>['Kyiv, Ukraine'],
        ],
        placesResponses: <Object>[
          <Place>[
            _place(id: 'gate', name: 'Golden Gate'),
            _place(id: 'square', name: 'Market Square'),
          ],
        ],
      );

      await _pumpApp(tester, repository: repository);

      await tester.ensureVisible(find.text('Calm'));
      await tester.tap(find.text('Calm'));
      await tester.pump();
      await tester.ensureVisible(find.text('Mixed'));
      await tester.tap(find.text('Mixed'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Generate Plan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Golden Gate').first);
      await tester.pumpAndSettle();

      expect(find.text('Mark as Visited'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Mark as Visited'));
      await tester.pumpAndSettle();

      expect(find.text('Visited'), findsOneWidget);
    });

    testWidgets('shows retry flow when city loading fails first', (tester) async {
      // Recovery-сценарій:
      // перше завантаження міст падає, після Retry список має підтягнутись.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          StateError('temporary db issue'),
          <String>['Kyiv, Ukraine'],
        ],
        placesResponses: <Object>[
          <Place>[_place(id: 'gate', name: 'Golden Gate')],
        ],
      );

      await _pumpApp(tester, repository: repository);

      expect(
        find.text(
          'Could not load cities from PostgreSQL. Check host, port, database, username, and password.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Kyiv, Ukraine'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Retry'), findsNothing);
    });

    testWidgets('changes locale from settings dialog and updates navigation labels', (
      tester,
    ) async {
      // Важчий тест на глобальний стан застосунку:
      // після збереження налаштувань тексти навігації мають змінитись.
      final repository = _SequenceTravelRepository(
        citiesResponses: <Object>[
          <String>['Kyiv, Ukraine'],
        ],
        placesResponses: <Object>[
          <Place>[_place(id: 'gate', name: 'Golden Gate')],
        ],
      );

      final ukL10n = AppLocalizations(const Locale('uk'));

      await _pumpApp(tester, repository: repository);

      expect(find.text('Generate'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ukrainian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text(ukL10n.navGenerate()), findsOneWidget);
      expect(find.text(ukL10n.navPlan()), findsOneWidget);
      expect(find.text(ukL10n.navMap()), findsOneWidget);
    });
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required TravelRepository repository,
}) async {
  await tester.pumpWidget(
    TravelApp(repository: repository, initialLocale: const Locale('en')),
  );
  await tester.pumpAndSettle();
}

ElevatedButton _generateButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Generate Plan'),
  );
}

Place _place({
  required String id,
  required String name,
  Importance importance = Importance.high,
  String category = 'Culture',
}) {
  // Хелпер для компактного створення Place у widget-тестах.
  return Place(
    id: id,
    name: name,
    importance: importance,
    category: category,
    description: 'A must-see stop in the historic center.',
    lat: 50.4501,
    lng: 30.5234,
  );
}

class _SequenceTravelRepository implements TravelRepository {
  // Репозиторій для widget-тестів, який повертає наперед задану
  // послідовність результатів: спершу помилку, потім успіх тощо.
  _SequenceTravelRepository({
    required List<Object> citiesResponses,
    required List<Object> placesResponses,
  }) : _citiesResponses = List<Object>.from(citiesResponses),
       _placesResponses = List<Object>.from(placesResponses);

  final List<Object> _citiesResponses;
  final List<Object> _placesResponses;

  @override
  Future<List<String>> fetchCities() async {
    return _takeNext<List<String>>(_citiesResponses);
  }

  @override
  Future<List<Place>> fetchPlacesForCity(String city) async {
    return _takeNext<List<Place>>(_placesResponses);
  }

  T _takeNext<T>(List<Object> responses) {
    if (responses.isEmpty) {
      throw StateError('No more fake responses configured.');
    }

    final next = responses.removeAt(0);
    if (next is Exception || next is Error) {
      throw next;
    }

    return next as T;
  }
}

class _DelayedTravelRepository implements TravelRepository {
  // Фейковий репозиторій із затримкою, щоб можна було протестувати loading UI.
  const _DelayedTravelRepository({
    required this.cities,
    required this.places,
    required this.delay,
  });

  final List<String> cities;
  final List<Place> places;
  final Duration delay;

  @override
  Future<List<String>> fetchCities() async {
    return cities;
  }

  @override
  Future<List<Place>> fetchPlacesForCity(String city) async {
    await Future<void>.delayed(delay);
    return places;
  }
}
