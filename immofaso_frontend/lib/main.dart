import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Ajoutez cet import
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // 2. Ajoutez l'import généré par la CLI Firebase (voir note plus bas)
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/notifications/notifications_gate.dart';

// 3. Modifiez la fonction main pour qu'elle soit asynchrone (async)
void main() async {
  // 4. Obligatoire pour exécuter du code asynchrone avant le runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // 5. Initialisez Firebase avec les options de votre projet
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ÉCRIVEZ CE BLOC ICI POUR LE TESTER
  String? token = await FirebaseMessaging.instance.getToken();
  print("---------- MON TOKEN FCM ----------");
  print(token);
  print("-----------------------------------");

  runApp(const ProviderScope(child: ImmoFasoApp()));
}

class ImmoFasoApp extends ConsumerWidget {
  const ImmoFasoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) => NotificationsGate(child: child!),
    );
  }
}
