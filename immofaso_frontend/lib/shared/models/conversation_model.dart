/// Entité MESSAGE — cf. dictionnaire de données.
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.expediteurId,
    required this.contenu,
    required this.envoyeLe,
    this.lu = false,
  });

  final String id;
  final String conversationId;
  final String expediteurId;
  final String contenu;
  final DateTime envoyeLe;
  final bool lu;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        expediteurId: json['expediteurId'] as String,
        contenu: json['contenu'] as String? ?? '',
        envoyeLe: DateTime.parse(json['envoyeLe'] as String),
        lu: json['lu'] as bool? ?? false,
      );
}

/// Entité CONVERSATION — rattachée à une ANNONCE, entre un locataire et
/// un propriétaire.
class Conversation {
  const Conversation({
    required this.id,
    required this.annonceId,
    required this.annonceTitre,
    required this.interlocuteurId,
    required this.interlocuteurNom,
    this.dernierMessage,
    this.dernierMessageLe,
    this.nonLus = 0,
  });

  final String id;
  final String annonceId;
  final String annonceTitre;
  final String interlocuteurId;
  final String interlocuteurNom;
  final String? dernierMessage;
  final DateTime? dernierMessageLe;
  final int nonLus;

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        annonceId: json['annonceId'] as String,
        annonceTitre: json['annonceTitre'] as String? ?? '',
        interlocuteurId: json['interlocuteurId'] as String,
        interlocuteurNom: json['interlocuteurNom'] as String? ?? '',
        dernierMessage: json['dernierMessage'] as String?,
        dernierMessageLe: json['dernierMessageLe'] != null
            ? DateTime.parse(json['dernierMessageLe'] as String)
            : null,
        nonLus: json['nonLus'] as int? ?? 0,
      );
}