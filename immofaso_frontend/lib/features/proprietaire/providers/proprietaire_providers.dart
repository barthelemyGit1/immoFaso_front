import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/annonce_model.dart';
import '../../../shared/models/dashboard_stats_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/proprietaire_repository.dart';

final proprietaireRepositoryProvider = Provider<ProprietaireRepository>((ref) {
  return ProprietaireRepository(apiClient: ref.watch(apiClientProvider));
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final repository = ref.watch(proprietaireRepositoryProvider);
  return repository.getDashboardStats();
});

final mesAnnoncesProvider = FutureProvider.autoDispose<List<Annonce>>((ref) async {
  final repository = ref.watch(proprietaireRepositoryProvider);
  return repository.getMesAnnonces();
});