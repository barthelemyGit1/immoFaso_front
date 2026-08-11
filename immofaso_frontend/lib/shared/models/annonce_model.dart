import 'dart:convert';

/// Statut de modération d'une annonce — cf. workflow de validation admin
/// du document de conception (entité ANNONCE.statut).
enum StatutAnnonce { enAttente, validee, rejetee, louee }

extension StatutAnnonceX on StatutAnnonce {
  String get label => switch (this) {
    StatutAnnonce.enAttente => 'En attente',
    StatutAnnonce.validee => 'Validée',
    StatutAnnonce.rejetee => 'Rejetée',
    StatutAnnonce.louee => 'Louée',
  };

  String get apiValue => switch (this) {
    StatutAnnonce.enAttente => 'EN_ATTENTE',
    StatutAnnonce.validee => 'VALIDEE',
    StatutAnnonce.rejetee => 'REJETEE',
    StatutAnnonce.louee => 'LOUEE',
  };

  static StatutAnnonce fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'VALIDEE':
        return StatutAnnonce.validee;
      case 'REJETEE':
        return StatutAnnonce.rejetee;
      case 'LOUEE':
        return StatutAnnonce.louee;
      case 'EN_ATTENTE':
      default:
        return StatutAnnonce.enAttente;
    }
  }
}

/// Type de logement — correspond aux catégories du dictionnaire de données
/// (entité ANNONCE.typeLogement) et aux filtres de recherche.
enum TypeLogement { villa, appartement, studio, chambre }

extension TypeLogementX on TypeLogement {
  String get label => switch (this) {
    TypeLogement.villa => 'Villa',
    TypeLogement.appartement => 'Appartement',
    TypeLogement.studio => 'Studio',
    TypeLogement.chambre => 'Chambre',
  };

  String get apiValue => name.toLowerCase(); // 'villa', 'appartement', etc.

  static TypeLogement fromApiValue(String value) {
    return TypeLogement.values.firstWhere(
      (t) => t.apiValue == value.toLowerCase(),
      orElse: () => TypeLogement.villa,
    );
  }
}

/// Équipements disponibles pour un logement (filtres + badges sur le détail).
enum Equipement { eau, electricite, wifi, ventilation, climatisation }

extension EquipementX on Equipement {
  String get label => switch (this) {
    Equipement.eau => 'Eau',
    Equipement.electricite => 'Électricité',
    Equipement.ventilation => 'Ventilation',
    Equipement.climatisation => 'Climatisation',
    Equipement.wifi => 'Wifi',
  };

  String get apiValue => name.toLowerCase(); // 'eau', 'wifi', etc.

  static Equipement fromApiValue(String value) {
    return Equipement.values.firstWhere(
      (e) => e.apiValue == value.toLowerCase(),
      orElse: () => Equipement.eau,
    );
  }
}

/// --- Helpers de parsing numérique tolérant ---
/// Laravel renvoie souvent les colonnes `decimal` (prix_mois, surface,
/// latitude, longitude...) comme des CHAÎNES JSON (ex: "120000") plutôt
/// que des nombres. Un cast direct `as num?` plante dans ce cas — ces
/// helpers acceptent num OU String indifféremment.
num? _tryNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

double? _tryDouble(dynamic value) => _tryNum(value)?.toDouble();

int? _tryInt(dynamic value) => _tryNum(value)?.toInt();

/// Entité PHOTO — rattachée à une ANNONCE.
class Photo {
  const Photo({required this.id, required this.url, this.ordre = 0});

  final String id;
  final String url;
  final int ordre;

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    id: json['id'].toString(),
    url: json['url'] as String,
    ordre: _tryInt(json['ordre']) ?? 0,
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
    required this.surface,
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
    this.statut = StatutAnnonce.enAttente,
    this.vues = 0,
  });

  final String id;
  final String titre;
  final String description;
  final TypeLogement typeLogement;
  final String ville;
  final String quartier;
  final num prixMensuel;
  final int nombrePieces;
  final num surface;
  final List<Equipement> equipements;
  final List<Photo> photos;
  final String proprietaireId;
  final String proprietaireNom;
  final double? latitude;
  final double? longitude;
  final double? proprietaireNote;
  final bool isFavori;
  final StatutAnnonce statut;
  final int vues;

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
    // Parsing sécurisé du champ equipements (gère List, String JSON, ou String séparée par des virgules)
    List<Equipement> parsedEquipements = [];
    final rawEquipements = json['equipements'];

    if (rawEquipements is List) {
      parsedEquipements = rawEquipements
          .map((e) => EquipementX.fromApiValue(e.toString()))
          .toList();
    } else if (rawEquipements is String && rawEquipements.isNotEmpty) {
      if (rawEquipements.startsWith('[')) {
        // Cas où le back renvoie une chaîne JSON d'un tableau ex: '["eau","wifi"]'
        try {
          final List<dynamic> decoded = jsonDecode(rawEquipements);
          parsedEquipements = decoded
              .map((e) => EquipementX.fromApiValue(e.toString()))
              .toList();
        } catch (_) {}
      } else {
        // Cas où le back renvoie une chaîne séparée par des virgules ex: "eau,wifi"
        parsedEquipements = rawEquipements
            .split(',')
            .map((e) => EquipementX.fromApiValue(e.trim()))
            .toList();
      }
    }

    // Parsing sécurisé du champ photos
    List<Photo> parsedPhotos = [];
    final rawPhotos = json['photos'];
    if (rawPhotos is List) {
      parsedPhotos = rawPhotos
          .map(
            (p) => Photo.fromJson(
              p is Map<String, dynamic> ? p : {'id': '', 'url': p.toString()},
            ),
          )
          .toList();
    }

    return Annonce(
      id: json['id']?.toString() ?? '',
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      typeLogement: TypeLogementX.fromApiValue(
        json['type_logement'] as String? ?? 'villa',
      ),
      ville: json['ville'] as String? ?? '',
      quartier: json['quartier'] as String? ?? '',
      surface: _tryNum(json['surface']) ?? 0,
      prixMensuel: _tryNum(json['prix_mois']) ?? 0,
      nombrePieces:
          _tryInt(json['nombre_pieces'] ?? json['nombrePieces']) ?? 0,
      equipements: parsedEquipements,
      photos: parsedPhotos,
      proprietaireId:
          json['proprietaire_id']?.toString() ??
          json['id_proprietaire']?.toString() ??
          json['proprietaireId']?.toString() ??
          '',
      proprietaireNom:
          json['proprietaire_nom'] as String? ??
          json['proprietaireNom'] as String? ??
          '',
      latitude: _tryDouble(json['latitude']),
      longitude: _tryDouble(json['longitude']),
      proprietaireNote:
          _tryDouble(json['proprietaire_note']) ??
          _tryDouble(json['proprietaireNote']),
      isFavori:
          json['is_favori'] as bool? ?? json['isFavori'] as bool? ?? false,
      statut: StatutAnnonceX.fromApiValue(json['statut'] as String?),
      vues: _tryInt(json['vues']) ?? 0,
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
      surface: surface,
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
      statut: statut,
      vues: vues,
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
      typeLogement: clearTypeLogement
          ? null
          : (typeLogement ?? this.typeLogement),
      budgetMax: budgetMax ?? this.budgetMax,
      equipements: equipements ?? this.equipements,
    );
  }

  Map<String, dynamic> toQueryParams() => {
    if (villeOuQuartier != null && villeOuQuartier!.isNotEmpty)
      'q': villeOuQuartier,
    if (typeLogement != null) 'type_logement': typeLogement!.apiValue,
    if (budgetMax != null) 'prix_mois': budgetMax,
    if (equipements.isNotEmpty)
      'equipements': equipements.map((e) => e.apiValue).toList(),
  };
}