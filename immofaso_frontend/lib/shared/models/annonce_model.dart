/// Type de logement — correspond aux catégories du dictionnaire de données
/// (entité ANNONCE.typeLogement) et aux filtres de recherche.
enum TypeLogement { villa, appartement, studio, chambre }

extension TypeLogementX on TypeLogement {
  String get label => switch (this) {
        TypeLogement.villa => 'Villas',
        TypeLogement.appartement => 'Appartements',
        TypeLogement.studio => 'Studio',
        TypeLogement.chambre => 'Chambres',
      };

  String get apiValue => name.toUpperCase();

  static TypeLogement fromApiValue(String value) {
    return TypeLogement.values.firstWhere(
      (t) => t.apiValue == value.toUpperCase(),
      orElse: () => TypeLogement.villa,
    );
  }
}

/// Équipements disponibles pour un logement (filtres + badges sur le détail).
enum Equipement { eau, electricite, internet, climatisation, wifi }

extension EquipementX on Equipement {
  String get label => switch (this) {
        Equipement.eau => 'Eau',
        Equipement.electricite => 'Électricité',
        Equipement.internet => 'Internet',
        Equipement.climatisation => 'Climatisation',
        Equipement.wifi => 'Wifi',
      };

  String get apiValue => name.toUpperCase();

  static Equipement fromApiValue(String value) {
    return Equipement.values.firstWhere(
      (e) => e.apiValue == value.toUpperCase(),
      orElse: () => Equipement.eau,
    );
  }
}

/// Entité PHOTO — rattachée à une ANNONCE.
class Photo {
  const Photo({required this.id, required this.url, this.ordre = 0});

  final String id;
  final String url;
  final int ordre;

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'] as String,
        url: json['url'] as String,
        ordre: json['ordre'] as int? ?? 0,
      );
}

/// Entité ANNONCE (version mobile) — cf. dictionnaire de données du
/// document de conception.
class Annonce {
  const Annonce({
    required this.id,
    required this.titre,
    required this.description,
    required this.typeLogement,
    required this.ville,
    required this.quartier,
    required this.prixMensuel,
    required this.nombrePieces,
    required this.equipements,
    required this.photos,
    required this.proprietaireId,
    required this.proprietaireNom,
    this.latitude,
    this.longitude,
    this.proprietaireNote,
    this.isFavori = false,
  });

  final String id;
  final String titre;
  final String description;
  final TypeLogement typeLogement;
  final String ville;
  final String quartier;
  final num prixMensuel;
  final int nombrePieces;
  final List<Equipement> equipements;
  final List<Photo> photos;
  final String proprietaireId;
  final String proprietaireNom;
  final double? latitude;
  final double? longitude;
  final double? proprietaireNote;
  final bool isFavori;

  String get localisation => '$quartier, $ville';

  /// Ex: "70 000 F CFA/mois"
  String get prixFormate {
    final str = prixMensuel.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '$buffer F CFA/mois';
  }

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: json['id'] as String,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      typeLogement: TypeLogementX.fromApiValue(json['typeLogement'] as String? ?? 'VILLA'),
      ville: json['ville'] as String? ?? '',
      quartier: json['quartier'] as String? ?? '',
      prixMensuel: json['prixMensuel'] as num? ?? 0,
      nombrePieces: json['nombrePieces'] as int? ?? 0,
      equipements: (json['equipements'] as List<dynamic>? ?? [])
          .map((e) => EquipementX.fromApiValue(e as String))
          .toList(),
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((p) => Photo.fromJson(p as Map<String, dynamic>))
          .toList(),
      proprietaireId: json['proprietaireId'] as String? ?? '',
      proprietaireNom: json['proprietaireNom'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      proprietaireNote: (json['proprietaireNote'] as num?)?.toDouble(),
      isFavori: json['isFavori'] as bool? ?? false,
    );
  }

  Annonce copyWith({bool? isFavori}) {
    return Annonce(
      id: id,
      titre: titre,
      description: description,
      typeLogement: typeLogement,
      ville: ville,
      quartier: quartier,
      prixMensuel: prixMensuel,
      nombrePieces: nombrePieces,
      equipements: equipements,
      photos: photos,
      proprietaireId: proprietaireId,
      proprietaireNom: proprietaireNom,
      latitude: latitude,
      longitude: longitude,
      proprietaireNote: proprietaireNote,
      isFavori: isFavori ?? this.isFavori,
    );
  }
}

/// Critères de recherche — sérialisés en query params pour CA-ANNONCE-list.
class RechercheFiltres {
  const RechercheFiltres({
    this.villeOuQuartier,
    this.typeLogement,
    this.budgetMax,
    this.equipements = const [],
  });

  final String? villeOuQuartier;
  final TypeLogement? typeLogement;
  final num? budgetMax;
  final List<Equipement> equipements;

  RechercheFiltres copyWith({
    String? villeOuQuartier,
    TypeLogement? typeLogement,
    num? budgetMax,
    List<Equipement>? equipements,
    bool clearTypeLogement = false,
  }) {
    return RechercheFiltres(
      villeOuQuartier: villeOuQuartier ?? this.villeOuQuartier,
      typeLogement: clearTypeLogement ? null : (typeLogement ?? this.typeLogement),
      budgetMax: budgetMax ?? this.budgetMax,
      equipements: equipements ?? this.equipements,
    );
  }

  Map<String, dynamic> toQueryParams() => {
        if (villeOuQuartier != null && villeOuQuartier!.isNotEmpty) 'q': villeOuQuartier,
        if (typeLogement != null) 'typeLogement': typeLogement!.apiValue,
        if (budgetMax != null) 'budgetMax': budgetMax,
        if (equipements.isNotEmpty) 'equipements': equipements.map((e) => e.apiValue).join(','),
      };
}