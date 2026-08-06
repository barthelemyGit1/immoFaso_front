/// Statistiques affichées sur le dashboard propriétaire (écran "Accueil").
class DashboardStats {
  const DashboardStats({
    required this.annoncesActives,
    required this.vuesCeMois,
    required this.messagesNonLus,
    required this.noteMoyenne,
  });

  final int annoncesActives;
  final int vuesCeMois;
  final int messagesNonLus;
  final double noteMoyenne;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        annoncesActives: json['annoncesActives'] as int? ?? 0,
        vuesCeMois: json['vuesCeMois'] as int? ?? 0,
        messagesNonLus: json['messagesNonLus'] as int? ?? 0,
        noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 0,
      );
}