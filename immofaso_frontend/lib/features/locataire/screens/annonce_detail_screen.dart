import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/annonce_model.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../messagerie/providers/conversation_providers.dart';
import '../../messagerie/screens/conversation_screen.dart';
import '../providers/annonce_providers.dart';

/// Écran "Details" de la maquette.
class AnnonceDetailScreen extends ConsumerStatefulWidget {
  const AnnonceDetailScreen({super.key, required this.annonceId});

  final String annonceId;

  @override
  ConsumerState<AnnonceDetailScreen> createState() =>
      _AnnonceDetailScreenState();
}

class _AnnonceDetailScreenState extends ConsumerState<AnnonceDetailScreen> {
  bool _isContacting = false;

  Future<void> _contacterProprietaire() async {
    setState(() => _isContacting = true);
    try {
      final conversation = await ref
          .read(conversationRepositoryProvider)
          .demarrerOuRecuperer(annonceId: widget.annonceId);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConversationScreen(conversation: conversation),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Impossible de contacter le propriétaire pour le moment.",
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isContacting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(annonceDetailProvider(widget.annonceId));

    return Scaffold(
      body: AsyncValueView<Annonce>(
        value: detail,
        onRetry: () => ref.invalidate(annonceDetailProvider(widget.annonceId)),
        data: (context, annonce) => _AnnonceDetailContent(
          annonce: annonce,
          isContacting: _isContacting,
          onContacter: _contacterProprietaire,
        ),
      ),
    );
  }
}

class _AnnonceDetailContent extends ConsumerWidget {
  const _AnnonceDetailContent({
    required this.annonce,
    required this.isContacting,
    required this.onContacter,
  });

  final Annonce annonce;
  final bool isContacting;
  final VoidCallback onContacter;

  // String get proprietaireNom => annonce.proprietaireId; // Assuming the property is named proprietaireId

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 240,
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              actions: [
                IconButton(
                  icon: Icon(
                    annonce.isFavori ? Icons.favorite : Icons.favorite_border,
                    color: annonce.isFavori ? AppColors.error : null,
                  ),
                  onPressed: () {
                    ref
                        .read(annonceRepositoryProvider)
                        .toggleFavori(annonce.id, isFavori: !annonce.isFavori);
                    ref.invalidate(annonceDetailProvider(annonce.id));
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _PhotoCarousel(photos: annonce.photos),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      annonce.titre,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          annonce.localisation,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text( annonce.prixFormate,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${annonce.nombrePieces} pièces • ${annonce.typeLogement.label}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (annonce.equipements.isNotEmpty) ...[
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: annonce.equipements
                            .map((e) => _EquipementBadge(equipements: e))
                            .toList(),
                      ),
                      const Divider(height: 32, color: AppColors.border),
                    ],
                    _ProprietaireCard(
                      nom: annonce.proprietaireNom,
                      note: annonce.proprietaireNote,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      annonce.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: ElevatedButton.icon(
            onPressed: isContacting ? null : onContacter,
            icon: isContacting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sms_outlined),
            label: const Text('Contacter le propriétaire'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5372A),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.photos});
  final List<Photo> photos;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return Container(
        color: AppColors.border,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: widget.photos.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) => Image.network(
            widget.photos[i].url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.border,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.photos.length, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _EquipementBadge extends StatelessWidget {
  const _EquipementBadge({required this.equipements});
  final Equipement equipements;

  IconData get _icon => switch (equipements) {
    Equipement.eau => Icons.water_drop_outlined,
    Equipement.electricite => Icons.bolt_outlined,
    Equipement.ventilation => Icons.air_outlined,
    Equipement.climatisation => Icons.ac_unit_outlined,
    Equipement.wifi => Icons.router_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 6),
        Text(equipements.label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ProprietaireCard extends StatelessWidget {
  const _ProprietaireCard({required this.nom, this.note});
  final String nom;
  final double? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.background,
            child: Icon(Icons.person, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom.isNotEmpty ? nom : 'Propriétaire',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (note != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        note!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                else
                  Text(
                    'Propriétaire',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
