import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/postgres_travel_repository.dart';
import 'data/travel_repository.dart';
import 'l10n/app_localizations.dart';
import 'models/travel_models.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/place_details_screen.dart';
import 'screens/plan_screen.dart';

void main() => runApp(const TravelApp());

class TravelApp extends StatefulWidget {
  const TravelApp({super.key});

  @override
  State<TravelApp> createState() => _TravelAppState();
}

class _TravelAppState extends State<TravelApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('uk');

  void _handleThemeModeChanged(ThemeMode value) {
    setState(() {
      _themeMode = value;
    });
  }

  void _handleLocaleChanged(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('uk')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF65A9FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      home: MainNavigation(
        themeMode: _themeMode,
        locale: _locale,
        onThemeModeChanged: _handleThemeModeChanged,
        onLocaleChanged: _handleLocaleChanged,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
    required this.themeMode,
    required this.locale,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Locale> onLocaleChanged;

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
    final l10n = AppLocalizations.of(context);
    final screens = <Widget>[
      HomeScreen(
        onGenerate: _handleGenerate,
        repository: _repository,
        themeMode: widget.themeMode,
        locale: widget.locale,
        onThemeModeChanged: widget.onThemeModeChanged,
        onLocaleChanged: widget.onLocaleChanged,
      ),
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.navGenerate(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today),
            label: l10n.navPlan(),
          ),
          NavigationDestination(icon: const Icon(Icons.map), label: l10n.navMap()),
        ],
      ),
    );
  }
}
