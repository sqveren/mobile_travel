import 'package:flutter/material.dart';

import '../models/travel_models.dart';

class PlaceDetailsScreenView extends StatelessWidget {
  const PlaceDetailsScreenView({
    super.key,
    required this.place,
    required this.isVisited,
    required this.importanceColors,
    required this.categoryColors,
    required this.onToggleVisited,
  });

  final Place place;
  final bool isVisited;
  final Map<String, Color> importanceColors;
  final Map<String, Color> categoryColors;
  final VoidCallback onToggleVisited;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Back',
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade200, Colors.purple.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _Tag(
                      text: place.category,
                      icon: Icons.tag,
                      colors: categoryColors,
                    ),
                    _Tag(
                      text: '${place.importance.label} Priority',
                      icon: Icons.star,
                      colors: importanceColors,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoCard(
                  title: 'Description',
                  content: Text(
                    place.description,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      height: 1.6,
                    ),
                  ),
                ),
                _InfoCard(
                  title: 'Location',
                  content: Column(
                    children: [
                      _CoordRow('Latitude', place.lat.toStringAsFixed(6)),
                      const SizedBox(height: 8),
                      _CoordRow('Longitude', place.lng.toStringAsFixed(6)),
                    ],
                  ),
                ),
                _InfoCard(
                  title: 'Visit Status',
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isVisited
                            ? 'You have visited this place'
                            : 'Not visited yet',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isVisited
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Back to Plan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: onToggleVisited,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isVisited ? Colors.green : Colors.transparent,
                      ),
                      backgroundColor: isVisited
                          ? Colors.green.withValues(alpha: 0.05)
                          : Colors.green,
                      foregroundColor: isVisited ? Colors.green : Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isVisited ? 'Visited' : 'Mark as Visited'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    required this.icon,
    required this.colors,
  });

  final String text;
  final IconData icon;
  final Map<String, Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors['text']!.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors['text']),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: colors['text'],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}

class _CoordRow extends StatelessWidget {
  const _CoordRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
