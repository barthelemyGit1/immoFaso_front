import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/annonce_model.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../providers/annonce_providers.dart';
import '../../widgets/brand_header.dart';
import '../annonce_detail_screen.dart';

/// Écran "Maps" de la maquette. Utilise OpenStreetMap via flutter_map
/// (pas de clé API à gérer, contrairement à Google Maps).
class CarteTab extends ConsumerWidget {
  const CarteTab({super.key});

  static const _centreBoboDioulasso = LatLng(11.1771, -4.2979);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annonces = ref.watch(annoncesCarteProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const BrandHeader(),
          Expanded(
            child: AsyncValueView<List<Annonce>>(
              value: annonces,
              onRetry: () => ref.invalidate(annoncesCarteProvider),
              emptyIcon: Icons.map_outlined,
              data: (context, list) {
                final markers = list
                    .where((a) => a.latitude != null && a.longitude != null)
                    .map((a) => Marker(
                          point: LatLng(a.latitude!, a.longitude!),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AnnonceDetailScreen(annonceId: a.id)),
                            ),
                            child: const Icon(Icons.location_on, color: Color(0xFFB5372A), size: 40),
                          ),
                        ))
                    .toList();

                return FlutterMap(
                  options: const MapOptions(
                    initialCenter: _centreBoboDioulasso,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'bf.immofaso.mobile',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}