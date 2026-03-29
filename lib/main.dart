import 'package:flutter/material.dart';

import 'data/city_tourist_places.dart';
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

  void _handleGenerate(String city, int days) {
    setState(() {
      _plan = _generatePlan(city, days);
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

  List<DayPlan> _generatePlan(String city, int days) {
    final safeDays = days.clamp(1, 7);
    final templates = getTouristPlacesForCity(city);

    return List<DayPlan>.generate(safeDays, (index) {
      final startIndex = (index * 3) % templates.length;
      final first = templates[startIndex];
      final second = templates[(startIndex + 1) % templates.length];
      final third = templates[(startIndex + 2) % templates.length];

      return DayPlan(
        day: index + 1,
        places: <Place>[
          _copyPlace(first, index, 0),
          _copyPlace(second, index, 1),
          _copyPlace(third, index, 2),
        ],
      );
    });
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
      HomeScreen(onGenerate: _handleGenerate),
      PlanScreen(
        plan: _plan,
        visitedPlaces: _visitedPlaces,
        onToggleVisited: _toggleVisited,
        onOpenMap: _openMap,
        onSelectPlace: _openPlaceDetails,
      ),
      MapScreen(
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
