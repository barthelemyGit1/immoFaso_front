import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Heure du dernier message + coches de lecture (si c'est mon message).
class HeureEtCoches extends StatelessWidget {
  const HeureEtCoches({
    super.key,
    required this.date,
    required this.estMien,
    required this.lu,
  });

  final DateTime? date;
  final bool estMien;
  final bool lu;

  static const _bleuLu = Color(0xFF34B7F1);

  String _format(DateTime d) {
    final local = d.toLocal();
    final now = DateTime.now();
    final aujourdhui = DateTime(now.year, now.month, now.day);
    final jour = DateTime(local.year, local.month, local.day);
    final ecart = aujourdhui.difference(jour).inDays;

    if (ecart == 0) {
      return '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    }
    if (ecart == 1) return 'Hier';
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year % 100}';
  }

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coches : seulement si le dernier message est le mien
        if (estMien) ...[
          Icon(
            lu ? Icons.done_all : Icons.done,
            size: 16,
            color: lu ? _bleuLu : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          _format(date!),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}