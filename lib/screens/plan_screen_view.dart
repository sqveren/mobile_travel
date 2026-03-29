import 'package:flutter/material.dart';

import '../models/travel_models.dart';

class PlanScreenView extends StatelessWidget {
  const PlanScreenView({
    super.key,
    required this.plan,
    required this.totalPlaces,
    required this.visitedCount,
    required this.progressPercentage,
    required this.isDayExpanded,
    required this.dayVisitedCount,
    required this.isVisited,
    required this.getImportanceColor,
    required this.getImportanceBackground,
    required this.onToggleDay,
    required this.onToggleVisited,
    required this.onOpenMap,
    required this.onSelectPlace,
  });

  final List<DayPlan> plan;
  final int totalPlaces;
  final int visitedCount;
  final double progressPercentage;
  final bool Function(int dayNumber) isDayExpanded;
  final int Function(DayPlan dayPlan) dayVisitedCount;
  final bool Function(Place place) isVisited;
  final Color Function(Importance importance) getImportanceColor;
  final Color Function(Importance importance) getImportanceBackground;
  final ValueChanged<int> onToggleDay;
  final ValueChanged<String> onToggleVisited;
  final VoidCallback onOpenMap;
  final ValueChanged<Place> onSelectPlace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 140,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Travel Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Visited $visitedCount of $totalPlaces places',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          plan.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No plan yet. Go to Generate and create your trip.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: plan.length,
                  itemBuilder: (context, index) {
                    final dayPlan = plan[index];
                    final expanded = isDayExpanded(dayPlan.day);
                    final visitedForDay = dayVisitedCount(dayPlan);

                    return _DayPlanCard(
                      dayPlan: dayPlan,
                      isExpanded: expanded,
                      visitedCount: visitedForDay,
                      isVisited: isVisited,
                      getImportanceColor: getImportanceColor,
                      getImportanceBackground: getImportanceBackground,
                      onToggleDay: onToggleDay,
                      onToggleVisited: onToggleVisited,
                      onSelectPlace: onSelectPlace,
                    );
                  },
                ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: onOpenMap,
              icon: const Icon(Icons.map_outlined),
              label: const Text('View on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPlanCard extends StatelessWidget {
  const _DayPlanCard({
    required this.dayPlan,
    required this.isExpanded,
    required this.visitedCount,
    required this.isVisited,
    required this.getImportanceColor,
    required this.getImportanceBackground,
    required this.onToggleDay,
    required this.onToggleVisited,
    required this.onSelectPlace,
  });

  final DayPlan dayPlan;
  final bool isExpanded;
  final int visitedCount;
  final bool Function(Place place) isVisited;
  final Color Function(Importance importance) getImportanceColor;
  final Color Function(Importance importance) getImportanceBackground;
  final ValueChanged<int> onToggleDay;
  final ValueChanged<String> onToggleVisited;
  final ValueChanged<Place> onSelectPlace;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => onToggleDay(dayPlan.day),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${dayPlan.day}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${dayPlan.day}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$visitedCount/${dayPlan.places.length} visited',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Column(
              children: [
                Divider(height: 1, color: Colors.grey.shade100),
                ...dayPlan.places.map(
                  (place) => _PlaceItem(
                    place: place,
                    isVisited: isVisited(place),
                    importanceColor: getImportanceColor(place.importance),
                    importanceBackground:
                        getImportanceBackground(place.importance),
                    onToggleVisited: onToggleVisited,
                    onSelectPlace: onSelectPlace,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PlaceItem extends StatelessWidget {
  const _PlaceItem({
    required this.place,
    required this.isVisited,
    required this.importanceColor,
    required this.importanceBackground,
    required this.onToggleVisited,
    required this.onSelectPlace,
  });

  final Place place;
  final bool isVisited;
  final Color importanceColor;
  final Color importanceBackground;
  final ValueChanged<String> onToggleVisited;
  final ValueChanged<Place> onSelectPlace;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelectPlace(place),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isVisited,
                onChanged: (_) => onToggleVisited(place.id),
                activeColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: importanceBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          place.importance.label,
                          style: TextStyle(
                            color: importanceColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        place.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
