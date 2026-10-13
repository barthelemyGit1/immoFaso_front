import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';

class _MapException implements Exception {
  const _MapException(this.message);
  final String message;
}

class AnnonceMapScreen extends StatefulWidget {
  const AnnonceMapScreen({
    super.key,
    required this.titre,
    required this.latitude,
    required this.longitude,
  });

  final String titre;
  final double latitude;
  final double longitude;

  @override
  State<AnnonceMapScreen> createState() => _AnnonceMapScreenState();
}

class _AnnonceMapScreenState extends State<AnnonceMapScreen> {
  final _mapController = MapController();
  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  late final LatLng _destination = LatLng(widget.latitude, widget.longitude);
  LatLng? _origine;
  List<LatLng> _itineraire = [];
  double? _distanceMetres;
  double? _dureeSecondes;
  bool _isLoading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final position = await _obtenirPosition();
      final origine = LatLng(position.latitude, position.longitude);
      final route = await _calculerItineraire(origine, _destination);
      if (!mounted) return;
      setState(() {
        _origine = origine;
        _itineraire = route.points;
        _distanceMetres = route.distance;
        _dureeSecondes = route.duration;
        _isLoading = false;
      });
      _ajusterCamera();
    } on _MapException catch (e) {
      _echec(e.message);
    } catch (_) {
      _echec("Impossible de calculer l'itinéraire pour le moment.");
    }
  }

  void _echec(String message) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _isLoading = false;
    });
  }

  Future<Position> _obtenirPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const _MapException(
        "Active la localisation de ton téléphone pour voir l'itinéraire.",
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const _MapException(
        "Autorise l'accès à ta position pour voir l'itinéraire.",
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const _MapException(
        "L'accès à la position est bloqué. Autorise-le dans les paramètres de l'application.",
      );
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  Future<({List<LatLng> points, double distance, double duration})>
      _calculerItineraire(LatLng a, LatLng b) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${a.longitude},${a.latitude};${b.longitude},${b.latitude}';
    final response = await _dio.get(
      url,
      queryParameters: {'overview': 'full', 'geometries': 'geojson'},
    );
    final routes = response.data['routes'] as List? ?? [];
    if (routes.isEmpty) {
      throw const _MapException("Aucun itinéraire trouvé jusqu'au logement.");
    }
    final route = routes.first as Map<String, dynamic>;
    final coords = route['geometry']['coordinates'] as List;
    return (
      // GeoJSON : [longitude, latitude]
      points: coords
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList(),
      distance: (route['distance'] as num).toDouble(),
      duration: (route['duration'] as num).toDouble(),
    );
  }

  void _ajusterCamera() {
    final points = [..._itineraire, ?_origine, _destination];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.fromLTRB(40, 60, 40, 180),
        ),
      );
    });
  }

  String get _distanceTexte {
    final m = _distanceMetres;
    if (m == null) return '';
    return m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(1)} km';
  }

  String get _dureeTexte {
    final s = _dureeSecondes;
    if (s == null) return '';
    final minutes = (s / 60).round();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60} h ${(minutes % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titre, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _destination,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.immofaso_frontend',
              ),
              if (_itineraire.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _itineraire,
                      strokeWidth: 5,
                      color: Colors.blue,
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_origine != null)
                    Marker(
                      point: _origine!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  Marker(
                    point: _destination,
                    width: 48,
                    height: 48,
                    alignment: Alignment.topCenter, // la pointe du pin = le logement
                    child: const Icon(Icons.location_on, size: 48, color: Colors.red),
                  ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (_isLoading)
            const Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Calcul de l\'itinéraire…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _message != null
                ? _InfoCard(
                    child: Row(
                      children: [
                        Expanded(child: Text(_message!)),
                        TextButton(
                          onPressed: _charger,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _dureeSecondes != null
                    ? _InfoCard(
                        child: Row(
                          children: [
                            const Icon(Icons.directions_car_outlined, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '$_dureeTexte • $_distanceTexte',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Recentrer',
                              icon: const Icon(Icons.center_focus_strong_outlined),
                              onPressed: _ajusterCamera,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}