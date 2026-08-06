import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/conversation_model.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../messagerie/providers/conversation_providers.dart';
import '../../../messagerie/screens/conversation_screen.dart';

/// Écran "Chat" côté propriétaire : liste des conversations avec les
/// locataires intéressés par ses annonces.
class MessagesProprietaireTab extends ConsumerWidget {
  const MessagesProprietaireTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const BrandHeader(),
          Expanded(
            child: AsyncValueView<List<Conversation>>(
              value: conversations,
              onRetry: () => ref.invalidate(conversationsProvider),
              isEmpty: (list) => list.isEmpty,
              emptyIcon: Icons.chat_bubble_outline_rounded,
              emptyTitle: 'Aucune conversation',
              emptyMessage: 'Les locataires intéressés par vos annonces apparaîtront ici.',
              data: (context, list) => ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final conversation = list[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.background,
                      child: Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                    title: Text(conversation.interlocuteurNom, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      conversation.dernierMessage ?? conversation.annonceTitre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (conversation.dernierMessageLe != null)
                          Text(
                            DateFormat('HH:mm').format(conversation.dernierMessageLe!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (conversation.nonLus > 0) ...[
                          const SizedBox(height: 4),
                          CircleAvatar(
                            radius: 9,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${conversation.nonLus}',
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ConversationScreen(conversation: conversation)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}