import 'package:flutter/material.dart';

import 'data/postgres_travel_repository.dart';
import 'data/travel_repository.dart';
import 'models/travel_models.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/place_details_screen.dart';
import 'screens/plan_screen.dart';

void main() => runApp(const TravelApp());

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<DayPlan> _plan = <DayPlan>[];
  final Set<String> _visitedPlaces = <String>{};
  final TravelRepository _repository = PostgresTravelRepository();

  Future<void> _handleGenerate(
    String city,
    int days,
    String pace,
    String travelType,
  ) async {
    final plan = await _generatePlan(city, days, pace, travelType);
    if (!mounted) {
      return;
    }

    setState(() {
      _plan = plan;
      _visitedPlaces.clear();
      _selectedIndex = 1;
    });
  }

  void _toggleVisited(String id) {
    setState(() {
      if (_visitedPlaces.contains(id)) {
        _visitedPlaces.remove(id);
      } else {
        _visitedPlaces.add(id);
      }
    });
  }

  void _openMap() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _openPlaceDetails(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaceDetailsScreen(
          place: place,
          isVisited: _visitedPlaces.contains(place.id),
          onToggleVisited: () => _toggleVisited(place.id),
        ),
      ),
    );
  }

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

      return DayPlan(
        day: index + 1,
        places: dayPlaces,
      );
    });
  }

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

  int _categoryRank(String category, Map<String, int> categoryPriority) {
    return categoryPriority[category.toLowerCase()] ?? 99;
  }

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

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(onGenerate: _handleGenerate, repository: _repository),
      PlanScreen(
        plan: _plan,
        visitedPlaces: _visitedPlaces,
        onToggleVisited: _toggleVisited,
        onOpenMap: _openMap,
        onSelectPlace: _openPlaceDetails,
      ),
      MapScreen(
        isActive: _selectedIndex == 2,
        plan: _plan,
        visitedPlaces: _visitedPlaces,
        onSelectPlace: _openPlaceDetails,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.settings), label: 'Generate'),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Plan',
          ),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}
