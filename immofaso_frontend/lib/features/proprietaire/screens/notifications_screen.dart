// lib/features/locataire/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textSecondary),
              SizedBox(height: 12),
              Text('Aucune notification pour le moment.'),
            ],
          ),
        ),
      ),
    );
  }
}