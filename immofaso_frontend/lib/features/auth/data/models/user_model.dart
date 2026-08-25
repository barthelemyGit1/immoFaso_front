import '../../../../core/constants/app_constants.dart';

/// Représente l'entité UTILISATEUR (cf. dictionnaire de données du
/// document de conception), version simplifiée côté mobile.
class UserModel {
  const UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    this.email,
    this.photoUrl,
    this.isVerified = false,
  });

  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final UserRole role;
  final String? email;
  final String? photoUrl;
  final bool isVerified;

  String get nomComplet => '$prenom $nom';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Laravel renvoie un id entier (auto-increment) ; on le convertit
      // en String pour rester cohérent avec le reste de l'app.
      id: json['id'].toString(),
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
      isVerified: json['isVerified'] as bool? ??
          json['is_verified'] as bool? ??
          json['telephone_verified_at'] != null,
      role: UserRoleX.fromApiValue(json['role'] as String? ?? 'LOCATAIRE'),
    );
  }
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'email': email,
        'photoUrl': photoUrl,
        'isVerified': isVerified,
        'role': role.apiValue,
      };

  UserModel copyWith({bool? isVerified, String? photoUrl}) {
    return UserModel(
      id: id,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      role: role,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
