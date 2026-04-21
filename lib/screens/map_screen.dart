import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../l10n/app_localizations.dart';
import '../models/travel_models.dart';
import 'map_screen_view.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.isActive,
    required this.plan,
    required this.visitedPlaces,
    required this.onSelectPlace,
  });

  final bool isActive;
  final List<DayPlan> plan;
  final Set<String> visitedPlaces;
  final ValueChanged<Place> onSelectPlace;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  Place? _selectedMarker;
  LatLng? _userLocation;
  String? _locationMessage;
  bool _isLocating = false;
  bool _mapReady = false;
  bool _didRequestInitialLocation = false;

  // Об'єднує всі місця з денних планів у список унікальних точок для мапи.
  List<Place> get _allPlaces {
    final uniquePlaces = <String, Place>{};
    for (final day in widget.plan) {
      for (final place in day.places) {
        uniquePlaces.putIfAbsent(
          '${place.name}-${place.lat}-${place.lng}',
          () => place,
        );
      }
    }
    return uniquePlaces.values.toList();
  }

  List<LatLng> get _routePoints =>
      _allPlaces.map((place) => LatLng(place.lat, place.lng)).toList();

  // Визначає стартовий центр мапи: спочатку користувач, потім перша точка маршруту.
  LatLng get _initialCenter {
    if (_userLocation != null) {
      return _userLocation!;
    }
    if (_allPlaces.isNotEmpty) {
      return LatLng(_allPlaces.first.lat, _allPlaces.first.lng);
    }
    return const LatLng(50.4501, 30.5234);
  }

  @override
  void initState() {
    super.initState();
    _scheduleInitialLocationIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _scheduleInitialLocationIfNeeded();
    }
    if (oldWidget.plan != widget.plan && _mapReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToContent();
      });
    }
  }

  // Планує початковий запит геолокації тільки тоді, коли вкладка мапи справді активна.
  void _scheduleInitialLocationIfNeeded() {
    if (!widget.isActive || _didRequestInitialLocation) {
      return;
    }

    _didRequestInitialLocation = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _requestLocation();
      }
    });
  }

  // Отримує поточну геолокацію користувача з перевіркою сервісів і дозволів.
  Future<void> _requestLocation() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = l10n.enableLocationServices;
          _isLocating = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = l10n.locationPermissionDenied;
          _isLocating = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = l10n.locationPermissionDeniedForever;
          _isLocating = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLocating = false;
      });

      _fitMapToContent();
    } catch (_) {
      setState(() {
        _locationMessage = l10n.locationLoadError;
        _isLocating = false;
      });
    }
  }

  // Позначає мапу готовою до роботи і підганяє камеру під маршрут.
  void _handleMapReady() {
    _mapReady = true;
    _fitMapToContent();
  }

  // Масштабує мапу так, щоб у кадрі були всі точки маршруту і позиція користувача.
  void _fitMapToContent() {
    if (!_mapReady) {
      return;
    }

    final coordinates = <LatLng>[
      ..._routePoints,
      if (_userLocation != null) _userLocation!,
    ];

    if (coordinates.isEmpty) {
      return;
    }

    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: coordinates,
        padding: const EdgeInsets.fromLTRB(56, 104, 56, 220),
        maxZoom: 15.5,
      ),
    );
  }

  // Вибирає маркер і центрує мапу на відповідному місці.
  void _handleMarkerTap(Place place) {
    setState(() {
      _selectedMarker = place;
    });

    if (_mapReady) {
      _mapController.move(LatLng(place.lat, place.lng), 15);
    }
  }

  // Закриває нижню картку з інформацією про вибране місце.
  void _handleCloseSelectedMarker() {
    setState(() {
      _selectedMarker = null;
    });
  }

  // Переміщує камеру до користувача або повторно запитує геолокацію.
  void _centerOnUser() {
    final userLocation = _userLocation;
    if (userLocation == null) {
      _requestLocation();
      return;
    }

    _mapController.move(userLocation, 15);
  }

  // Збільшує масштаб мапи.
  void _zoomIn() {
    if (!_mapReady) {
      return;
    }

    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  // Зменшує масштаб мапи.
  void _zoomOut() {
    if (!_mapReady) {
      return;
    }

    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  // Перевіряє, чи місце вже відмічено як відвідане.
  bool _isVisited(Place place) => widget.visitedPlaces.contains(place.id);

  // Повертає колір маркера залежно від visited-стану і пріоритету місця.
  Color _getMarkerColor(Place place) {
    if (_isVisited(place)) {
      return Colors.green;
    }

    switch (place.importance) {
      case Importance.high:
        return Colors.red;
      case Importance.medium:
        return Colors.orange;
      case Importance.low:
        return Colors.blue;
    }
  }

  // Будує допоміжну лінію між користувачем і вибраною точкою на мапі.
  List<LatLng> get _selectedConnection {
    final userLocation = _userLocation;
    final selectedMarker = _selectedMarker;
    if (userLocation == null || selectedMarker == null) {
      return const <LatLng>[];
    }

    return <LatLng>[
      userLocation,
      LatLng(selectedMarker.lat, selectedMarker.lng),
    ];
  }

  // Розраховує текстову відстань від користувача до вибраного місця.
  String? get _selectedDistanceLabel {
    final l10n = AppLocalizations.of(context);
    final userLocation = _userLocation;
    final selectedMarker = _selectedMarker;
    if (userLocation == null || selectedMarker == null) {
      return null;
    }

    final meters = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      selectedMarker.lat,
      selectedMarker.lng,
    );

    if (meters < 1000) {
      return l10n.metersAway(meters.round());
    }

    return l10n.kilometersAway((meters / 1000).toStringAsFixed(1));
  }

  // Розраховує текстовий напрямок до вибраного місця.
  String? get _selectedDirectionLabel {
    final userLocation = _userLocation;
    final selectedMarker = _selectedMarker;
    if (userLocation == null || selectedMarker == null) {
      return null;
    }

    final bearing = Geolocator.bearingBetween(
      userLocation.latitude,
      userLocation.longitude,
      selectedMarker.lat,
      selectedMarker.lng,
    );

    return AppLocalizations.of(context).direction(_bearingToDirection(bearing));
  }

  // Перетворює азимут у зрозумілий напрямок типу north / south-west.
  String _bearingToDirection(double bearing) {
    const directions = <String>[
      'north',
      'north-east',
      'east',
      'south-east',
      'south',
      'south-west',
      'west',
      'north-west',
    ];
    final normalized = (bearing + 360) % 360;
    final index = ((normalized + 22.5) ~/ 45) % directions.length;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.expand();
    }

    return MapScreenView(
      mapController: _mapController,
      allPlaces: _allPlaces,
      routePoints: _routePoints,
      selectedConnection: _selectedConnection,
      selectedMarker: _selectedMarker,
      initialCenter: _initialCenter,
      userLocation: _userLocation,
      isLocating: _isLocating,
      locationMessage: _locationMessage,
      isVisited: _isVisited,
      getMarkerColor: _getMarkerColor,
      selectedDistanceLabel: _selectedDistanceLabel,
      selectedDirectionLabel: _selectedDirectionLabel,
      onMapReady: _handleMapReady,
      onMarkerTap: _handleMarkerTap,
      onCloseSelectedMarker: _handleCloseSelectedMarker,
      onSelectPlace: widget.onSelectPlace,
      onCenterOnUser: _centerOnUser,
      onZoomIn: _zoomIn,
      onZoomOut: _zoomOut,
      onFitRoute: _fitMapToContent,
      onRetryLocation: _requestLocation,
    );
  }
}
