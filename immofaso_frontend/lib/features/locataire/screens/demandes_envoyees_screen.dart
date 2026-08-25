// lib/features/locataire/screens/demandes_envoyees_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../messagerie/providers/conversation_providers.dart';
import '../../messagerie/screens/conversation_screen.dart';

class DemandesEnvoyeesScreen extends ConsumerWidget {
  const DemandesEnvoyeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes demandes envoyées')),
      body: AsyncValueView<List<Conversation>>(
        value: conversations,
        onRetry: () => ref.invalidate(conversationsProvider),
        data: (context, items) {
          if (items.isEmpty) {
            return const Center(child: Text('Aucune demande envoyée pour le moment.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final conversation = items[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.background,
                  child: Icon(Icons.person, color: AppColors.textSecondary),
                ),
                title: Text(
                  conversation.interlocuteurNom.isNotEmpty
                      ? conversation.interlocuteurNom
                      : 'Propriétaire',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  conversation.annonceTitre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: conversation.nonLus > 0
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '${conversation.nonLus}',
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(conversation: conversation),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}