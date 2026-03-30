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
  });

  final Future<void> Function(
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
  bool _isGenerating = false;
  String? _loadError;
  String? _generateError;
  bool _didLoadCities = false;

  @override
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
      !_isGenerating &&
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

  void _handleCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
    });
  }

  void _handleDaysChanged(String _) {
    setState(() {});
  }

  void _handlePaceChanged(String pace) {
    setState(() {
      _pace = pace;
    });
  }

  void _handleTravelTypeChanged(String travelType) {
    setState(() {
      _travelType = travelType;
    });
  }

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

  Future<void> _handleGeneratePressed() async {
    final l10n = AppLocalizations.of(context);
    final selectedCity = _selectedCity;
    final days = int.tryParse(_daysController.text);
    if (selectedCity == null || days == null || days <= 0) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _generateError = null;
    });

    try {
      await widget.onGenerate(selectedCity, days, _pace, _travelType);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _generateError = l10n.databaseGenerateError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
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
      isGenerating: _isGenerating,
      loadError: _generateError ?? _loadError,
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
