import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/travel_repository.dart';
import '../models/travel_models.dart';

enum TravelPlannerStatus { initial, loading, success, failure }

enum TravelPlannerErrorType { generatePlan }

sealed class TravelPlannerEvent {
  const TravelPlannerEvent();
}

class TravelPlanRequested extends TravelPlannerEvent {
  const TravelPlanRequested({
    required this.city,
    required this.days,
    required this.pace,
    required this.travelType,
  });

  final String city;
  final int days;
  final String pace;
  final String travelType;
}

class TravelPlaceVisitedToggled extends TravelPlannerEvent {
  const TravelPlaceVisitedToggled(this.placeId);

  final String placeId;
}

class TravelPlannerState {
  const TravelPlannerState({
    this.plan = const <DayPlan>[],
    this.visitedPlaces = const <String>{},
    this.status = TravelPlannerStatus.initial,
    this.errorType,
  });

  final List<DayPlan> plan;
  final Set<String> visitedPlaces;
  final TravelPlannerStatus status;
  final TravelPlannerErrorType? errorType;

  bool get isGenerating => status == TravelPlannerStatus.loading;

  TravelPlannerState copyWith({
    List<DayPlan>? plan,
    Set<String>? visitedPlaces,
    TravelPlannerStatus? status,
    TravelPlannerErrorType? errorType,
    bool clearError = false,
  }) {
    return TravelPlannerState(
      plan: plan ?? this.plan,
      visitedPlaces: visitedPlaces ?? this.visitedPlaces,
      status: status ?? this.status,
      errorType: clearError ? null : (errorType ?? this.errorType),
    );
  }
}

class TravelPlannerBloc
    extends Bloc<TravelPlannerEvent, TravelPlannerState> {
  // Bloc централізує бізнес-логіку планувальника:
  // генерацію маршруту, обробку помилок і список visited місць.
  TravelPlannerBloc({required TravelRepository repository})
    : _repository = repository,
      super(const TravelPlannerState()) {
    on<TravelPlanRequested>(_onTravelPlanRequested);
    on<TravelPlaceVisitedToggled>(_onTravelPlaceVisitedToggled);
  }

  final TravelRepository _repository;

  // Обробляє подію генерації нового маршруту:
  // переводить стан у loading, будує план і повертає success/failure.
  Future<void> _onTravelPlanRequested(
    TravelPlanRequested event,
    Emitter<TravelPlannerState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TravelPlannerStatus.loading,
        clearError: true,
      ),
    );

    try {
      final plan = await _generatePlan(
        event.city,
        event.days,
        event.pace,
        event.travelType,
      );

      emit(
        TravelPlannerState(
          plan: plan,
          visitedPlaces: const <String>{},
          status: TravelPlannerStatus.success,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TravelPlannerStatus.failure,
          errorType: TravelPlannerErrorType.generatePlan,
        ),
      );
    }
  }

  // Перемикає статус visited для конкретного місця без повторної генерації плану.
  void _onTravelPlaceVisitedToggled(
    TravelPlaceVisitedToggled event,
    Emitter<TravelPlannerState> emit,
  ) {
    final updatedVisitedPlaces = Set<String>.from(state.visitedPlaces);
    if (updatedVisitedPlaces.contains(event.placeId)) {
      updatedVisitedPlaces.remove(event.placeId);
    } else {
      updatedVisitedPlaces.add(event.placeId);
    }

    emit(
      state.copyWith(
        visitedPlaces: updatedVisitedPlaces,
        clearError: true,
      ),
    );
  }

  // Основний алгоритм побудови плану:
  // отримує місця з репозиторію, сортує їх і розкладає по днях.
  Future<List<DayPlan>> _generatePlan(
    String city,
    int days,
    String pace,
    String travelType,
  ) async {
    final safeDays = days.clamp(1, 7);
    final templates = await _repository.fetchPlacesForCity(city);
    final orderedTemplates = _prioritizePlaces(templates, travelType);
    final placesPerDay = _placesPerDayForPace(pace);

    if (orderedTemplates.isEmpty) {
      return <DayPlan>[];
    }

    return List<DayPlan>.generate(safeDays, (index) {
      final startIndex = (index * placesPerDay) % orderedTemplates.length;
      final dayPlaces = List<Place>.generate(placesPerDay, (placeOffset) {
        final template =
            orderedTemplates[(startIndex + placeOffset) % orderedTemplates.length];
        return _copyPlace(template, index, placeOffset);
      });

      return DayPlan(day: index + 1, places: dayPlaces);
    });
  }

  // Визначає інтенсивність маршруту: скільки місць показувати на один день.
  int _placesPerDayForPace(String pace) {
    switch (pace) {
      case 'calm':
        return 2;
      case 'active':
        return 4;
      case 'standard':
      default:
        return 3;
    }
  }

  // Упорядковує місця за пріоритетом та типом подорожі,
  // щоб маршрут виглядав більш релевантним для користувача.
  List<Place> _prioritizePlaces(List<Place> places, String travelType) {
    final categoryPriority = _categoryPriorityForTravelType(travelType);
    final prioritized = List<Place>.from(places);

    prioritized.sort((a, b) {
      final importanceCompare =
          _importanceRank(a.importance).compareTo(_importanceRank(b.importance));
      if (importanceCompare != 0) {
        return importanceCompare;
      }

      final categoryCompare = _categoryRank(
        a.category,
        categoryPriority,
      ).compareTo(_categoryRank(b.category, categoryPriority));
      if (categoryCompare != 0) {
        return categoryCompare;
      }

      return a.name.compareTo(b.name);
    });

    return prioritized;
  }

  // Дає числовий пріоритет для Importance, щоб можна було сортувати місця.
  int _importanceRank(Importance importance) {
    switch (importance) {
      case Importance.high:
        return 0;
      case Importance.medium:
        return 1;
      case Importance.low:
        return 2;
    }
  }

  // Формує пріоритет категорій під обраний сценарій подорожі.
  Map<String, int> _categoryPriorityForTravelType(String travelType) {
    switch (travelType) {
      case 'cultural':
        return <String, int>{
          'culture': 0,
          'art': 1,
          'city walk': 2,
          'scenic': 3,
          'nature': 4,
          'food': 5,
          'entertainment': 6,
        };
      case 'entertainment':
        return <String, int>{
          'entertainment': 0,
          'food': 1,
          'scenic': 2,
          'city walk': 3,
          'art': 4,
          'nature': 5,
          'culture': 6,
        };
      case 'mixed':
      default:
        return <String, int>{
          'culture': 0,
          'art': 1,
          'scenic': 2,
          'city walk': 3,
          'entertainment': 4,
          'nature': 5,
          'food': 6,
        };
    }
  }

  // Повертає числовий ранг категорії для подальшого сортування.
  int _categoryRank(String category, Map<String, int> categoryPriority) {
    return categoryPriority[category.toLowerCase()] ?? 99;
  }

  // Створює копію місця з новим id, щоб одна й та сама локація
  // могла використовуватись у різних днях плану як окремий елемент маршруту.
  Place _copyPlace(Place place, int dayIndex, int placeIndex) {
    return Place(
      id: '${place.id}-${dayIndex + 1}-${placeIndex + 1}',
      name: place.name,
      importance: place.importance,
      category: place.category,
      description: place.description,
      lat: place.lat,
      lng: place.lng,
    );
  }
}
