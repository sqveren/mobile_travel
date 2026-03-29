import 'package:flutter/material.dart';

import '../models/travel_models.dart';
import 'place_details_screen_view.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({
    super.key,
    required this.place,
    required this.isVisited,
    required this.onToggleVisited,
  });

  final Place place;
  final bool isVisited;
  final VoidCallback onToggleVisited;

  Map<String, Color> _getImportanceColors(Importance importance) {
    switch (importance) {
      case Importance.high:
        return {'bg': Colors.red.shade50, 'text': Colors.red.shade700};
      case Importance.medium:
        return {'bg': Colors.orange.shade50, 'text': Colors.orange.shade700};
      case Importance.low:
        return {'bg': Colors.green.shade50, 'text': Colors.green.shade700};
    }
  }

  Map<String, Color> _getCategoryColors(String category) {
    if (category.toLowerCase().contains('culture')) {
      return {'bg': Colors.purple.shade50, 'text': Colors.purple.shade700};
    }
    if (category.toLowerCase().contains('entertainment')) {
      return {'bg': Colors.pink.shade50, 'text': Colors.pink.shade700};
    }
    return {'bg': Colors.blue.shade50, 'text': Colors.blue.shade700};
  }

  @override
  Widget build(BuildContext context) {
    return PlaceDetailsScreenView(
      place: place,
      isVisited: isVisited,
      importanceColors: _getImportanceColors(place.importance),
      categoryColors: _getCategoryColors(place.category),
      onToggleVisited: onToggleVisited,
    );
  }
}
