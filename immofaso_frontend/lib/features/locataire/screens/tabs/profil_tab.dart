import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../widgets/brand_header.dart';

class ProfilTab extends ConsumerWidget {
  const ProfilTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const BrandHeader(),
          const SizedBox(height: 12),
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.background,
            child: Icon(Icons.person, size: 40, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(user?.nomComplet ?? '', style: Theme.of(context).textTheme.titleLarge),
          Text(user?.telephone ?? '', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          _ProfilTile(icon: Icons.favorite_border, label: 'Mes favoris', onTap: () {}),
          _ProfilTile(icon: Icons.description_outlined, label: 'Mes demandes envoyées', onTap: () {}),
          _ProfilTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
          _ProfilTile(icon: Icons.settings_outlined, label: 'Paramètres', onTap: () {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: OutlinedButton(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              child: const Text('Se déconnecter'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilTile extends StatelessWidget {
  const _ProfilTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}