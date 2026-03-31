import 'package:flutter/material.dart';

import '../data/travel_repository.dart';
import '../l10n/app_localizations.dart';
import 'home_screen_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onGenerate,
    required this.repository,
    required this.themeMode,
    required this.locale,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
    required this.isGenerating,
    required this.generateErrorMessage,
  });

  final void Function(
    String city,
    int days,
    String pace,
    String travelType,
  )
  onGenerate;
  final TravelRepository repository;
  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final bool isGenerating;
  final String? generateErrorMessage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCity = 'Kyiv, Ukraine';
  final TextEditingController _daysController = TextEditingController(
    text: '3',
  );
  String _pace = '';
  String _travelType = '';
  List<String> _cities = const <String>[];
  bool _isLoadingCities = true;
  String? _loadError;
  bool _didLoadCities = false;

  @override
  // Використовується для одноразового стартового завантаження списку міст з БД.
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadCities) {
      return;
    }

    _didLoadCities = true;
    _loadCities();
  }

  bool get _isFormValid =>
      !_isLoadingCities &&
      !widget.isGenerating &&
      _selectedCity != null &&
      _daysController.text.isNotEmpty &&
      (int.tryParse(_daysController.text) ?? 0) > 0 &&
      _pace.isNotEmpty &&
      _travelType.isNotEmpty;

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  // Оновлює вибране місто у формі генерації маршруту.
  void _handleCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
    });
  }

  // Перебудовує форму після зміни кількості днів.
  void _handleDaysChanged(String _) {
    setState(() {});
  }

  // Зберігає вибраний темп подорожі.
  void _handlePaceChanged(String pace) {
    setState(() {
      _pace = pace;
    });
  }

  // Зберігає вибраний тип подорожі.
  void _handleTravelTypeChanged(String travelType) {
    setState(() {
      _travelType = travelType;
    });
  }

  // Завантажує список доступних міст з PostgreSQL для випадаючого списку.
  Future<void> _loadCities() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoadingCities = true;
      _loadError = null;
    });

    try {
      final cities = await widget.repository.fetchCities();
      if (!mounted) {
        return;
      }

      setState(() {
        _cities = cities;
        _selectedCity = cities.contains(_selectedCity)
            ? _selectedCity
            : (cities.isEmpty ? null : cities.first);
        _isLoadingCities = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = l10n.databaseLoadError;
        _isLoadingCities = false;
      });
    }
  }

  // Перевіряє форму і відправляє параметри генерації в Bloc.
  Future<void> _handleGeneratePressed() async {
    final selectedCity = _selectedCity;
    final days = int.tryParse(_daysController.text);
    if (selectedCity == null || days == null || days <= 0) {
      return;
    }

    widget.onGenerate(selectedCity, days, _pace, _travelType);
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenView(
      cities: _cities,
      selectedCity: _selectedCity,
      daysController: _daysController,
      pace: _pace,
      travelType: _travelType,
      isFormValid: _isFormValid,
      isLoadingCities: _isLoadingCities,
      isGenerating: widget.isGenerating,
      loadError: widget.generateErrorMessage ?? _loadError,
      themeMode: widget.themeMode,
      locale: widget.locale,
      onCityChanged: _handleCityChanged,
      onDaysChanged: _handleDaysChanged,
      onPaceChanged: _handlePaceChanged,
      onTravelTypeChanged: _handleTravelTypeChanged,
      onGeneratePressed: _handleGeneratePressed,
      onRetryLoadCities: _loadCities,
      onThemeModeChanged: widget.onThemeModeChanged,
      onLocaleChanged: widget.onLocaleChanged,
    );
  }
}
