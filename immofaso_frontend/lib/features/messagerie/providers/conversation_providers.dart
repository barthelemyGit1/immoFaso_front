import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/conversation_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/conversation_repository.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository(apiClient: ref.watch(apiClientProvider));
});

final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getConversations();
});

final messagesProvider =
    FutureProvider.autoDispose.family<List<Message>, String>((ref, conversationId) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getMessages(conversationId);
});