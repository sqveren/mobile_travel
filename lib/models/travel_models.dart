enum Importance { high, medium, low }

extension ImportanceX on Importance {
  String get label {
    switch (this) {
      case Importance.high:
        return 'High';
      case Importance.medium:
        return 'Medium';
      case Importance.low:
        return 'Low';
    }
  }
}

class Place {
  final String id;
  final String name;
  final Importance importance;
  final String category;
  final String description;
  final double lat;
  final double lng;

  const Place({
    required this.id,
    required this.name,
    required this.importance,
    required this.category,
    required this.description,
    required this.lat,
    required this.lng,
  });
}

class DayPlan {
  final int day;
  final List<Place> places;

  const DayPlan({required this.day, required this.places});
}
