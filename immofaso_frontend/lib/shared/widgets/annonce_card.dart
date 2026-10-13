import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/annonce_model.dart';
// Adapte ce chemin à l'emplacement réel de ton écran détail.
import '../../features/locataire/screens/annonce_detail_screen.dart';

/// Carte compacte représentant une annonce dans une liste (accueil,
/// résultats de recherche, favoris). Au clic, ouvre l'écran détail.
class AnnonceCard extends StatefulWidget {
  const AnnonceCard({
    super.key,
    required this.annonce,
    this.onToggleFavori,
    this.onFavoriChanged,
  });

  final Annonce annonce;

  /// Appelé quand on clique sur le cœur de la carte (ton appel API existant).
  final ValueChanged<bool>? onToggleFavori;

  /// Appelé au retour de l'écran détail si le favori y a été modifié
  /// (utile pour retirer la carte de la liste des favoris, par exemple).
  final ValueChanged<bool>? onFavoriChanged;

  @override
  State<AnnonceCard> createState() => _AnnonceCardState();
}

class _AnnonceCardState extends State<AnnonceCard> {
  late bool _isFavori;

  @override
  void initState() {
    super.initState();
    _isFavori = widget.annonce.isFavori;
  }

  // Si le parent recharge la liste, on se resynchronise avec la valeur serveur.
  @override
  void didUpdateWidget(covariant AnnonceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.annonce.isFavori != widget.annonce.isFavori) {
      _isFavori = widget.annonce.isFavori;
    }
  }

  void _toggleFavori() {
    final nouvelEtat = !_isFavori;
    setState(() => _isFavori = nouvelEtat);
    widget.onToggleFavori?.call(nouvelEtat);
  }

  Future<void> _ouvrirDetail() async {
  final resultat = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => AnnonceDetailScreen(
        annonceId: widget.annonce.id,
        initialIsFavori: _isFavori, // état actuel du cœur de la carte
      ),
    ),
  );

  if (resultat != null && resultat != _isFavori) {
    if (mounted) setState(() => _isFavori = resultat);
    widget.onFavoriChanged?.call(resultat);
  }
}

  @override
  Widget build(BuildContext context) {
    final annonce = widget.annonce;

    return InkWell(
      onTap: _ouvrirDetail,
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
            _Thumbnail(
              photoUrl:
                  annonce.photos.isNotEmpty ? annonce.photos.first.url : null,
            ),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 15),
                        ),
                      ),
                      if (widget.onToggleFavori != null)
                        InkWell(
                          onTap: _toggleFavori,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              _isFavori ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: _isFavori
                                  ? Colors.red
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    annonce.prixFormate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${annonce.nombrePieces} pièces • ${annonce.typeLogement.label}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
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
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textSecondary,
                ),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
              ),
      ),
    );
  }
}