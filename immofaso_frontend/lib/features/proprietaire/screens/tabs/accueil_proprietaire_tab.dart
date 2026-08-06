import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/annonce_model.dart';
import '../../../../shared/models/dashboard_stats_model.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/proprietaire_providers.dart';
import '../../widgets/mon_annonce_title.dart';
import '../../widgets/stat_card.dart';
import '../publier_annonce_screen.dart';

/// Écran "Accueil" de la maquette propriétaire : statistiques,
/// bouton de publication, aperçu des annonces récentes.
class AccueilProprietaireTab extends ConsumerWidget {
  const AccueilProprietaireTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final nomComplet = authState is AuthAuthenticated ? authState.user.nomComplet : '';
    final stats = ref.watch(dashboardStatsProvider);
    final mesAnnonces = ref.watch(mesAnnoncesProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const BrandHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bonjour,', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
                  Text(nomComplet.toUpperCase(), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
                  const SizedBox(height: 16),
                  AsyncValueView<DashboardStats>(
                    value: stats,
                    onRetry: () => ref.invalidate(dashboardStatsProvider),
                    data: (context, s) => GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.7,
                      children: [
                        StatCard(label: 'Annonces actives', value: '${s.annoncesActives}', icon: Icons.local_offer_outlined),
                        StatCard(label: 'Vues ce mois', value: '${s.vuesCeMois}', icon: Icons.visibility_outlined),
                        StatCard(label: 'Messages non lus', value: '${s.messagesNonLus}', icon: Icons.chat_bubble_outline, iconColor: AppColors.secondary),
                        StatCard(label: 'Note moyenne', value: s.noteMoyenne.toStringAsFixed(1), icon: Icons.star_rounded, iconColor: AppColors.warning),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PublierAnnonceScreen()),
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Publier une annonce'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 212, 131, 25)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Mes annonces', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(color: AppColors.border),
                  AsyncValueView<List<Annonce>>(
                    value: mesAnnonces,
                    onRetry: () => ref.invalidate(mesAnnoncesProvider),
                    isEmpty: (list) => list.isEmpty,
                    emptyIcon: Icons.home_work_outlined,
                    emptyTitle: 'Aucune annonce publiée',
                    emptyMessage: "Cliquez sur \"Publier une annonce\" pour ajouter votre premier logement.",
                    data: (context, list) => Column(
                      children: list
                          .take(3)
                          .map((annonce) => MonAnnonceTile(
                                annonce: annonce,
                                onModifier: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PublierAnnonceScreen(annonceExistante: annonce),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}