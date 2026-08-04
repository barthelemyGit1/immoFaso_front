import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/conversation_model.dart';

/// Regroupe les appels réseau liés à la messagerie. Correspond aux
/// endpoints CA-MESSAGERIE-xx du contrat API :
///   GET  /conversations
///   POST /conversations                (créer/récupérer pour une annonce)
///   GET  /conversations/:id/messages
///   POST /conversations/:id/messages
///
/// Le temps réel (nouveaux messages, indicateur "en train d'écrire") passe
/// par Socket.io (cf. spec WebSocket du document de conception) — non
/// branché ici, cette classe ne couvre que le REST (historique + envoi).
class ConversationRepository {
  ConversationRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _api.raw.get('/conversations');
      final results = response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      return results.map((json) => Conversation.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Récupère la conversation existante pour cette annonce, ou en crée
  /// une nouvelle si c'est le premier contact (cf. bouton "Contacter le
  /// propriétaire" sur le détail d'une annonce).
  Future<Conversation> demarrerOuRecuperer({required String annonceId}) async {
    try {
      final response = await _api.raw.post('/conversations', data: {'annonceId': annonceId});
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _api.raw.get('/conversations/$conversationId/messages');
      final results = response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      return results.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Message> envoyerMessage({required String conversationId, required String contenu}) async {
    try {
      final response = await _api.raw.post(
        '/conversations/$conversationId/messages',
        data: {'contenu': contenu},
      );
      return Message.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}