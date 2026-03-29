import 'package:flutter/material.dart';

import 'home_screen_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onGenerate});

  final void Function(String city, int days) onGenerate;

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

  static const List<String> _cities = [
    'Paris, France',
    'Tokyo, Japan',
    'New York, USA',
    'Barcelona, Spain',
    'Rome, Italy',
    'London, UK',
    'Dubai, UAE',
    'Prague, Czech Republic',
    'Amsterdam, Netherlands',
    'Kyiv, Ukraine',
  ];

  bool get _isFormValid =>
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

  void _handleGeneratePressed() {
    final selectedCity = _selectedCity;
    final days = int.tryParse(_daysController.text);
    if (selectedCity == null || days == null || days <= 0) {
      return;
    }

    widget.onGenerate(selectedCity, days);
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
      onCityChanged: _handleCityChanged,
      onDaysChanged: _handleDaysChanged,
      onPaceChanged: _handlePaceChanged,
      onTravelTypeChanged: _handleTravelTypeChanged,
      onGeneratePressed: _handleGeneratePressed,
    );
  }
}
