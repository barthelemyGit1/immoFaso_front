import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/models/annonce_model.dart';
import '../../../../shared/widgets/annonce_card.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../providers/annonce_providers.dart';

/// Écran "Maps" : logements autour du locataire (OpenStreetMap + flutter_map).
class CarteTab extends ConsumerStatefulWidget {
  const CarteTab({super.key});

  @override
  ConsumerState<CarteTab> createState() => _CarteTabState();
}

class _CarteTabState extends ConsumerState<CarteTab> {
  static const _centreBoboDioulasso = LatLng(11.1771, -4.2979);
  static const _rayonKm = 5.0;

  final _mapController = MapController();

  void _afficherAnnonce(Annonce annonce) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        // AnnonceCard ouvre elle-même l'écran détail au clic.
        child: AnnonceCard(annonce: annonce),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(positionLocataireProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const BrandHeader(),
          Expanded(
            child: position.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _carte(null),
              data: _carte,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carte(LatLng? positionLocataire) {
    // Sans position, on cherche autour du centre de Bobo-Dioulasso.
    final centre = positionLocataire ?? _centreBoboDioulasso;
    final annonces = ref.watch(
      annoncesNearbyProvider((lat: centre.latitude, lng: centre.longitude)),
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: centre, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'bf.immofaso.mobile',
            ),
            // Zone de recherche
            CircleLayer(
              circles: [
                CircleMarker(
                  point: centre,
                  radius: _rayonKm * 1000,
                  useRadiusInMeter: true,
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderColor: Colors.blue.withValues(alpha: 0.4),
                  borderStrokeWidth: 1.5,
                ),
              ],
            ),
            // Logements autour
            MarkerLayer(
              markers: annonces.maybeWhen(
                data: (list) => list
                    .where((a) => a.latitude != null && a.longitude != null)
                    .map(
                      (a) => Marker(
                        point: LatLng(a.latitude!, a.longitude!),
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _afficherAnnonce(a),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFFB5372A),
                            size: 40,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                orElse: () => const <Marker>[],
              ),
            ),
            // Position du locataire
            if (positionLocataire != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: positionLocataire,
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
                ],
              ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),

        // Bandeau d'information en haut
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Column(
            children: [
              if (positionLocataire == null)
                const _Bandeau(
                  icon: Icons.location_off_outlined,
                  texte:
                      "Position indisponible : logements autour du centre de Bobo-Dioulasso.",
                ),
              annonces.when(
                loading: () => const _Bandeau(
                  icon: Icons.search,
                  texte: 'Recherche des logements proches… Veuillez patientez!',
                ),
                error: (_, __) => _Bandeau(
                  icon: Icons.error_outline,
                  texte: 'Impossible de charger les logements.',
                  action: TextButton(
                    onPressed: () => ref.invalidate(annoncesNearbyProvider),
                    child: const Text('Réessayer'),
                  ),
                ),
                data: (list) => _Bandeau(
                  icon: Icons.home_work_outlined,
                  texte: list.isEmpty
                      ? 'Aucun logement dans un rayon de ${_rayonKm.toInt()} km.'
                      : '${list.length} logement(s) dans un rayon de ${_rayonKm.toInt()} km.',
                ),
              ),
            ],
          ),
        ),

        // Bouton "Ma position"
        Positioned(
          right: 16,
          bottom: 24,
          child: FloatingActionButton.small(
            onPressed: () => _mapController.move(centre, 14),
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}

class _Bandeau extends StatelessWidget {
  const _Bandeau({required this.icon, required this.texte, this.action});

  final IconData icon;
  final String texte;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texte, style: Theme.of(context).textTheme.bodySmall),
          ),
          ?action,
        ],
      ),
    );
  }
}