import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Affiché pendant la tentative de restauration de session (auto-login).
/// Le router bascule automatiquement vers login/home dès que
/// [AuthController] a résolu son état initial.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/icons/icon2.png'),
              width: 148,
              height: 148,
            ),
            SizedBox(height: 16),
            Text(
              'ImmoFaso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
