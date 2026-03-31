import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/travel_planner_bloc.dart';
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

  // Зберігає глобально обрану тему застосунку.
  void _handleThemeModeChanged(ThemeMode value) {
    setState(() {
      _themeMode = value;
    });
  }

  // Зберігає глобально обрану мову застосунку.
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
  final TravelRepository _repository = PostgresTravelRepository();
  // Bloc створюється на рівні основної навігації, щоб його стан
  // був спільним для HomeScreen, PlanScreen і MapScreen.
  late final TravelPlannerBloc _travelPlannerBloc = TravelPlannerBloc(
    repository: _repository,
  );

  // Переключає вкладку застосунку на екран мапи.
  void _openMap() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  // Відкриває екран деталей місця і передає туди актуальний visited-стан.
  void _openPlaceDetails(
    BuildContext context,
    Place place,
    Set<String> visitedPlaces,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaceDetailsScreen(
          place: place,
          isVisited: visitedPlaces.contains(place.id),
          onToggleVisited: () {
            _travelPlannerBloc.add(TravelPlaceVisitedToggled(place.id));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _travelPlannerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider.value(
      value: _travelPlannerBloc,
      child: BlocListener<TravelPlannerBloc, TravelPlannerState>(
        // Після успішної генерації маршруту автоматично переводимо користувача на вкладку плану.
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == TravelPlannerStatus.success) {
            setState(() {
              _selectedIndex = 1;
            });
          }
        },
        child: BlocBuilder<TravelPlannerBloc, TravelPlannerState>(
          // Перебудовує основні екрани, коли змінюється стан плану або visited місць.
          builder: (context, state) {
            final generateErrorMessage =
                state.errorType == TravelPlannerErrorType.generatePlan
                ? AppLocalizations.of(context).databaseGenerateError
                : null;

            final screens = <Widget>[
              HomeScreen(
                onGenerate: (city, days, pace, travelType) {
                  _travelPlannerBloc.add(
                    TravelPlanRequested(
                      city: city,
                      days: days,
                      pace: pace,
                      travelType: travelType,
                    ),
                  );
                },
                repository: _repository,
                themeMode: widget.themeMode,
                locale: widget.locale,
                onThemeModeChanged: widget.onThemeModeChanged,
                onLocaleChanged: widget.onLocaleChanged,
                isGenerating: state.isGenerating,
                generateErrorMessage: generateErrorMessage,
              ),
              PlanScreen(
                plan: state.plan,
                visitedPlaces: state.visitedPlaces,
                onToggleVisited: (id) {
                  _travelPlannerBloc.add(TravelPlaceVisitedToggled(id));
                },
                onOpenMap: _openMap,
                onSelectPlace: (place) {
                  _openPlaceDetails(context, place, state.visitedPlaces);
                },
              ),
              MapScreen(
                isActive: _selectedIndex == 2,
                plan: state.plan,
                visitedPlaces: state.visitedPlaces,
                onSelectPlace: (place) {
                  _openPlaceDetails(context, place, state.visitedPlaces);
                },
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
                  NavigationDestination(
                    icon: const Icon(Icons.map),
                    label: l10n.navMap(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
