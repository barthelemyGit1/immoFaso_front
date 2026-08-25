// lib/features/locataire/screens/favoris_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/annonce_model.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/annonce_card.dart';
import '../providers/annonce_providers.dart';
import 'annonce_detail_screen.dart';

class FavorisScreen extends ConsumerWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoris = ref.watch(favorisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: AsyncValueView<List<Annonce>>(
        value: favoris,
        onRetry: () => ref.invalidate(favorisProvider),
        data: (context, items) {
          if (items.isEmpty) {
            return const Center(child: Text('Vous n\'avez pas encore de favoris.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final annonce = items[index];
              return AnnonceCard(
                annonce: annonce,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AnnonceDetailScreen(annonceId: annonce.id),
                    ),
                  );
                },
                onToggleFavori: (isFavori) {
                  ref
                      .read(annonceRepositoryProvider)
                      .toggleFavori(annonce.id, isFavori: isFavori);
                  ref.invalidate(favorisProvider);
                },
              );
            },
          );
        },
      ),
    );
  }
}