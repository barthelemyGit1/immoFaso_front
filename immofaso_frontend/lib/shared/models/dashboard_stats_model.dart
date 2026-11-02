/// Statistiques affichées sur le dashboard propriétaire (écran "Accueil").
class DashboardStats {
  const DashboardStats({
    required this.annoncesActives,
    required this.vues,
    required this.likes,
    required this.messagesNonLus,
  });

  final int annoncesActives;
  final int vues;
  final int likes;
  final int messagesNonLus;

  /// Construit les stats depuis la réponse de GET /statistiques/proprietaire.
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final annonces = json['annonces'] as List<dynamic>? ?? const [];
    final actives = annonces
        .where((a) => (a as Map<String, dynamic>)['statut'] == 'validee')
        .length;

    return DashboardStats(
      annoncesActives: actives,
      vues: (json['total_vues'] as num?)?.toInt() ?? 0,
      likes: (json['total_likes'] as num?)?.toInt() ?? 0,
      messagesNonLus: (json['total_messages_non_lus'] as num?)?.toInt() ?? 0,
    );
  }
}