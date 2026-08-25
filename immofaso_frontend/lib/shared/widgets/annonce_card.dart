import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/annonce_model.dart';

/// Carte compacte représentant une annonce dans une liste (accueil,
/// résultats de recherche, favoris).
class AnnonceCard extends StatelessWidget {
  const AnnonceCard({
    super.key,
    required this.annonce,
    required this.onTap,
    this.onToggleFavori,
  });

  final Annonce annonce;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggleFavori;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumbnail(photoUrl: annonce.photos.isNotEmpty ? annonce.photos.first.url : null),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          annonce.titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                        ),
                      ),
                      if (onToggleFavori != null)
                        InkWell(
                          onTap: () => onToggleFavori!(!annonce.isFavori),
                          child: Icon(
                            annonce.isFavori ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: annonce.isFavori ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    annonce.prixFormate,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${annonce.nombrePieces} pièces • ${annonce.typeLogement.label}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          annonce.quartier,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 84,
        height: 84,
        color: AppColors.background,
        child: photoUrl == null
            ? const Icon(Icons.image_outlined, color: AppColors.textSecondary)
            : Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
      ),
    );
  }
}