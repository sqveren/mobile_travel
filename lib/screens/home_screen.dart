import 'package:flutter/material.dart';

import '../data/travel_repository.dart';
import 'home_screen_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onGenerate,
    required this.repository,
  });

  final Future<void> Function(
    String city,
    int days,
    String pace,
    String travelType,
  )
  onGenerate;
  final TravelRepository repository;

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

  @override
  void initState() {
    super.initState();
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
        _loadError =
            'Could not load cities from PostgreSQL. Check host, port, database, username, and password.';
        _isLoadingCities = false;
      });
    }
  }

  Future<void> _handleGeneratePressed() async {
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
        _generateError =
            'Could not generate the plan from PostgreSQL. Check the data types and database connection.';
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
      onCityChanged: _handleCityChanged,
      onDaysChanged: _handleDaysChanged,
      onPaceChanged: _handlePaceChanged,
      onTravelTypeChanged: _handleTravelTypeChanged,
      onGeneratePressed: _handleGeneratePressed,
      onRetryLoadCities: _loadCities,
    );
  }
}
