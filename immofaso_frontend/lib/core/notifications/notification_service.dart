import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // App fermée ou en arrière-plan : Android affiche la notification tout seul.
}

class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'messages', // même id que côté Laravel
    'Messages',
    description: 'Nouveaux messages des conversations',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> init({
    required void Function() onMessageRecu,
    required void Function(Map<String, dynamic> data) onOuverture,
  }) async {
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) => onOuverture({}),
    );

    // App ouverte : FCM n'affiche rien, on affiche la notification nous-mêmes.
    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n != null) {
        _local.show(
          id: message.hashCode,
          title: n.title,
          body: n.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
      onMessageRecu();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((m) => onOuverture(m.data));
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) onOuverture(initial.data);
  }

  static Future<void> enregistrerToken(
    Future<void> Function(String token) envoyerAuServeur,
  ) async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await envoyerAuServeur(token);

    FirebaseMessaging.instance.onTokenRefresh.listen(envoyerAuServeur);
  }
}