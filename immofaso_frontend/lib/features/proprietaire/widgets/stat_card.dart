import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Carte "Annonces actives / Vues ce mois / Messages non lus / Note
/// moyenne" du dashboard propriétaire.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}