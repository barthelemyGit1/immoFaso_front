// lib/features/locataire/screens/parametres_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'change_password_screen.dart';
import 'apropos_screen.dart';

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _ParametreTile(icon: Icons.lock_outline, label: 'Changement de mot de passe', onTap: () {
              // Implémenter la navigation vers l'écran de changement de mot de passe
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },),
          _ParametreTile(icon: Icons.info_outline, label: 'À propos d\'ImmoFaso', onTap: () {
              // Implémenter la navigation vers l'écran "À propos"
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AproposScreen()),
              );
            },),
          
        ],
      ),
    );
  }
}

class _ParametreTile extends StatelessWidget {
  const _ParametreTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
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