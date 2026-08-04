import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/conversation_providers.dart';
import '../widgets/message_bubble.dart';

/// Écran "Chat" de la maquette : historique de messages + saisie.
/// Le temps réel (Socket.io) sera branché plus tard ; pour l'instant,
/// l'envoi d'un message rafraîchit simplement l'historique via REST.
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final texte = _messageController.text.trim();
    if (texte.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await ref.read(conversationRepositoryProvider).envoyerMessage(
            conversationId: widget.conversation.id,
            contenu: texte,
          );
      _messageController.clear();
      ref.invalidate(messagesProvider(widget.conversation.id));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'envoyer le message."), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.conversation.id));
    final currentUserId = switch (ref.watch(authControllerProvider)) {
      AuthAuthenticated(:final user) => user.id,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.background,
              child: Icon(Icons.person, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.conversation.interlocuteurNom, style: const TextStyle(fontSize: 15)),
                Text(
                  widget.conversation.annonceTitre,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AsyncValueView<List<Message>>(
              value: messages,
              onRetry: () => ref.invalidate(messagesProvider(widget.conversation.id)),
              isEmpty: (list) => list.isEmpty,
              emptyIcon: Icons.chat_bubble_outline_rounded,
              emptyTitle: 'Aucun message',
              emptyMessage: 'Démarrez la conversation en envoyant un message.',
              data: (context, msgs) => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final message = msgs[msgs.length - 1 - index];
                  return MessageBubble(message: message, isMine: message.expediteurId == currentUserId);
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _envoyer(),
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _envoyer,
                    icon: _isSending
                        ? const SizedBox(
                            height: 16, width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}