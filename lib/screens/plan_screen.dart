import 'package:flutter/material.dart';

import '../models/travel_models.dart';
import 'plan_screen_view.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    super.key,
    required this.plan,
    required this.visitedPlaces,
    required this.onToggleVisited,
    required this.onOpenMap,
    required this.onSelectPlace,
  });

  final List<DayPlan> plan;
  final Set<String> visitedPlaces;
  final ValueChanged<String> onToggleVisited;
  final VoidCallback onOpenMap;
  final ValueChanged<Place> onSelectPlace;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final Set<int> _expandedDays = <int>{1};

  int get _totalPlaces =>
      widget.plan.fold(0, (sum, day) => sum + day.places.length);

  int get _visitedCount => widget.visitedPlaces.length;

  double get _progressPercentage =>
      _totalPlaces > 0 ? _visitedCount / _totalPlaces : 0;

  void _toggleDay(int dayNumber) {
    setState(() {
      if (_expandedDays.contains(dayNumber)) {
        _expandedDays.remove(dayNumber);
      } else {
        _expandedDays.add(dayNumber);
      }
    });
  }

  Color _getImportanceColor(Importance importance) {
    switch (importance) {
      case Importance.high:
        return Colors.red.shade700;
      case Importance.medium:
        return Colors.orange.shade700;
      case Importance.low:
        return Colors.green.shade700;
    }
  }

  Color _getImportanceBackground(Importance importance) {
    switch (importance) {
      case Importance.high:
        return Colors.red.shade50;
      case Importance.medium:
        return Colors.orange.shade50;
      case Importance.low:
        return Colors.green.shade50;
    }
  }

  bool _isDayExpanded(int dayNumber) => _expandedDays.contains(dayNumber);

  int _dayVisitedCount(DayPlan dayPlan) {
    return dayPlan.places
        .where((place) => widget.visitedPlaces.contains(place.id))
        .length;
  }

  bool _isVisited(Place place) => widget.visitedPlaces.contains(place.id);

  @override
  Widget build(BuildContext context) {
    return PlanScreenView(
      plan: widget.plan,
      totalPlaces: _totalPlaces,
      visitedCount: _visitedCount,
      progressPercentage: _progressPercentage,
      isDayExpanded: _isDayExpanded,
      dayVisitedCount: _dayVisitedCount,
      isVisited: _isVisited,
      getImportanceColor: _getImportanceColor,
      getImportanceBackground: _getImportanceBackground,
      onToggleDay: _toggleDay,
      onToggleVisited: widget.onToggleVisited,
      onOpenMap: widget.onOpenMap,
      onSelectPlace: widget.onSelectPlace,
    );
  }
}
