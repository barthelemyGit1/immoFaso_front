import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/messagerie/providers/conversation_providers.dart';
import 'notification_service.dart';

class NotificationsGate extends ConsumerStatefulWidget {
  const NotificationsGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationsGate> createState() => _NotificationsGateState();
}

class _NotificationsGateState extends ConsumerState<NotificationsGate> {
  @override
  void initState() {
    super.initState();
    NotificationService.init(
      onMessageRecu: () => ref.invalidate(conversationsProvider),
      onOuverture: (_) => ref.invalidate(conversationsProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated && previous is! AuthAuthenticated) {
        NotificationService.enregistrerToken((token) async {
          await ref.read(apiClientProvider).raw.post(
           '/device-tokens',
           data: {'token': token, 'platform': 'android'},
         );
        });
      }
    });
    return widget.child;
  }
}