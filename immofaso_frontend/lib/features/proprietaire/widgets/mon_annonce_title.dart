import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/annonce_model.dart';

/// Ligne compacte "titre — Modifier / statut", utilisée dans la section
/// "Mes annonces" du dashboard propriétaire.
class MonAnnonceTile extends StatelessWidget {
  const MonAnnonceTile({super.key, required this.annonce, required this.onModifier});

  final Annonce annonce;
  final VoidCallback onModifier;

  Color get _statutColor => switch (annonce.statut) {
        StatutAnnonce.validee => AppColors.success,
        StatutAnnonce.enAttente => AppColors.warning,
        StatutAnnonce.rejetee => AppColors.error,
        StatutAnnonce.louee => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(annonce.typeLogement.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(annonce.prixMensuel > 0 ? '${annonce.prixMensuel} FCFA' : 'Pas encore de prix', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(annonce.statut.label, style: TextStyle(color: _statutColor, fontSize: 13)),
              ],
            ),
          ),
          TextButton(onPressed: onModifier, child: const Text('Modifier')),
        ],
      ),
    );
  }
}