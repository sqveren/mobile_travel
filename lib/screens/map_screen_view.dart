import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/travel_models.dart';

class MapScreenView extends StatelessWidget {
  const MapScreenView({
    super.key,
    required this.mapController,
    required this.allPlaces,
    required this.routePoints,
    required this.selectedConnection,
    required this.selectedMarker,
    required this.initialCenter,
    required this.userLocation,
    required this.isLocating,
    required this.locationMessage,
    required this.isVisited,
    required this.getMarkerColor,
    required this.selectedDistanceLabel,
    required this.selectedDirectionLabel,
    required this.onMapReady,
    required this.onMarkerTap,
    required this.onCloseSelectedMarker,
    required this.onSelectPlace,
    required this.onCenterOnUser,
    required this.onFitRoute,
    required this.onRetryLocation,
  });

  final MapController mapController;
  final List<Place> allPlaces;
  final List<LatLng> routePoints;
  final List<LatLng> selectedConnection;
  final Place? selectedMarker;
  final LatLng initialCenter;
  final LatLng? userLocation;
  final bool isLocating;
  final String? locationMessage;
  final bool Function(Place place) isVisited;
  final Color Function(Place place) getMarkerColor;
  final String? selectedDistanceLabel;
  final String? selectedDirectionLabel;
  final VoidCallback onMapReady;
  final ValueChanged<Place> onMarkerTap;
  final VoidCallback onCloseSelectedMarker;
  final ValueChanged<Place> onSelectPlace;
  final VoidCallback onCenterOnUser;
  final VoidCallback onFitRoute;
  final VoidCallback onRetryLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          allPlaces.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Generate a plan first to see real tourist points on the map.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 13,
                    onMapReady: onMapReady,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.my_app',
                    ),
                    if (routePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: Colors.blue.withValues(alpha: 0.65),
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    if (selectedConnection.length == 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: selectedConnection,
                            color: Colors.black87,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        ...allPlaces.map(
                          (place) => Marker(
                            point: LatLng(place.lat, place.lng),
                            width: 64,
                            height: 72,
                            child: _PlaceMarker(
                              place: place,
                              isSelected: selectedMarker?.id == place.id,
                              isVisited: isVisited(place),
                              color: getMarkerColor(place),
                              onTap: () => onMarkerTap(place),
                            ),
                          ),
                        ),
                        if (userLocation != null)
                          Marker(
                            point: userLocation!,
                            width: 32,
                            height: 32,
                            child: const _UserLocationMarker(),
                          ),
                      ],
                    ),
                  ],
                ),
          Positioned(
            top: 56,
            left: 16,
            right: 88,
            child: _MapHeader(
              placeCount: allPlaces.length,
              locationMessage: locationMessage,
              isLocating: isLocating,
              onRetryLocation: onRetryLocation,
            ),
          ),
          Positioned(
            top: 56,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'fit-route',
                  onPressed: onFitRoute,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.route, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'center-user',
                  onPressed: onCenterOnUser,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 180,
            left: 16,
            child: _MapLegend(),
          ),
          if (selectedMarker != null)
            _MapPlaceSheet(
              place: selectedMarker!,
              distanceLabel: selectedDistanceLabel,
              directionLabel: selectedDirectionLabel,
              onClose: onCloseSelectedMarker,
              onViewDetails: () => onSelectPlace(selectedMarker!),
            ),
        ],
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.placeCount,
    required this.locationMessage,
    required this.isLocating,
    required this.onRetryLocation,
  });

  final int placeCount;
  final String? locationMessage;
  final bool isLocating;
  final VoidCallback onRetryLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Map',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '$placeCount real tourist points on the route',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          if (isLocating) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Finding your current location...',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ] else if (locationMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              locationMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetryLocation,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Try location again'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendItem(color: Colors.red, label: 'High priority'),
          _LegendItem(color: Colors.orange, label: 'Medium priority'),
          _LegendItem(color: Colors.blue, label: 'Low priority'),
          _LegendItem(color: Colors.green, label: 'Visited'),
          _LegendItem(color: Colors.black87, label: 'Line from you'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker({
    required this.place,
    required this.isSelected,
    required this.isVisited,
    required this.color,
    required this.onTap,
  });

  final Place place;
  final bool isSelected;
  final bool isVisited;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 12,
                ),
              ],
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              place.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.location_on,
                  size: isSelected ? 38 : 34,
                  color: color,
                ),
                if (isVisited)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class _MapPlaceSheet extends StatelessWidget {
  const _MapPlaceSheet({
    required this.place,
    required this.distanceLabel,
    required this.directionLabel,
    required this.onClose,
    required this.onViewDetails,
  });

  final Place place;
  final String? distanceLabel;
  final String? directionLabel;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(
                  text: place.category,
                  background: Colors.blue.shade50,
                  foreground: Colors.blue.shade700,
                ),
                _Badge(
                  text: place.importance.label,
                  background: Colors.grey.shade100,
                  foreground: Colors.grey.shade700,
                ),
                if (distanceLabel != null)
                  _Badge(
                    text: distanceLabel!,
                    background: Colors.green.shade50,
                    foreground: Colors.green.shade700,
                  ),
                if (directionLabel != null)
                  _Badge(
                    text: directionLabel!,
                    background: Colors.orange.shade50,
                    foreground: Colors.orange.shade700,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              place.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(Icons.info_outline),
              label: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
