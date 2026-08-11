import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../shared/models/annonce_model.dart';
import '../../../shared/models/dashboard_stats_model.dart';

class ProprietaireRepository {
  ProprietaireRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  /// ⚠️ Pas d'endpoint dashboard côté Laravel pour l'instant (aucune route
  /// dans AnnonceController ne renvoie de stats agrégées). En attendant,
  /// on calcule "Annonces actives" à partir de `/annonces/all`. Les
  /// autres compteurs (vues, messages non lus, note moyenne) resteront à
  /// 0 tant que ces données ne sont pas exposées côté back.
  Future<DashboardStats> getDashboardStats() async {
    try {
      final mesAnnonces = await getMesAnnonces();
      final annoncesActives = mesAnnonces.where((a) => a.statut == StatutAnnonce.validee).length;
      final vuesTotal = mesAnnonces.fold<int>(0, (sum, a) => sum + a.vues);
      return DashboardStats(
        annoncesActives: annoncesActives,
        vuesCeMois: vuesTotal,
        messagesNonLus: 0,
        noteMoyenne: 0,
      );
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<List<Annonce>> getMesAnnonces() async {
    try {
      final response = await _api.raw.get('/annonces/all');
      final results =
          response.data['data'] as List<dynamic>? ??
          response.data as List<dynamic>;
      return results
          .map((json) => Annonce.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Annonce> publierAnnonce({
    required String titre,
    required String description,
    required TypeLogement typeLogement,
    required String ville,
    required String quartier,
    required num surface,
    required num prixMensuel,
    required int nombrePieces,
    required List<Equipement> equipements,
    double? latitude,
    double? longitude,
    List<File> photos = const [],
  }) async {
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('titre', titre),
        MapEntry('description', description),
        MapEntry('type_logement', typeLogement.apiValue),
        MapEntry('ville', ville),
        MapEntry('quartier', quartier),
        MapEntry('surface', surface.toString()),
        MapEntry('prix_mois', prixMensuel.toString()),
        MapEntry('nombre_pieces', nombrePieces.toString()),
        if (latitude != null) MapEntry('latitude', latitude.toString()),
        if (longitude != null) MapEntry('longitude', longitude.toString()),
      ]);

      for (final equipement in equipements) {
        formData.fields.add(MapEntry('equipements[]', equipement.apiValue));
      }

      for (final photo in photos) {
        formData.files.add(
          MapEntry(
            'photos[]',
            await MultipartFile.fromFile(photo.path, filename: photo.path.split('/').last),
          ),
        );
      }

      final response = await _api.raw.post('/annonces', data: formData);
      final rawData = response.data['data'] ?? response.data;
      return Annonce.fromJson(rawData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    } catch (e) {
      // Filet de sécurité : une erreur de parsing (ex: type inattendu
      // renvoyé par le back) ne doit pas remonter comme une exception
      // brute jusqu'à l'écran. L'annonce a très probablement été créée
      // côté serveur malgré cette erreur locale de lecture de la réponse.
      throw ApiException(
        message: "L'annonce a été créée, mais la réponse du serveur n'a pas pu être lue correctement.",
      );
    }
  }

  Future<Annonce> modifierAnnonce({
    required String annonceId,
    required String titre,
    required String description,
    required TypeLogement typeLogement,
    required String ville,
    required String quartier,
    required num surface,
    required num prixMensuel,
    required int nombrePieces,
    required List<Equipement> equipements,
    double? latitude,
    double? longitude,
    List<File> nouvellesPhotos = const [],
  }) async {
    try {
      final formData = FormData();

      // Laravel gère mal le multipart/form-data natif en PATCH.
      // On envoie en POST avec `_method=PUT` (method spoofing Laravel).
      formData.fields.addAll([
        MapEntry('_method', 'PUT'),
        MapEntry('titre', titre),
        MapEntry('description', description),
        MapEntry('type_logement', typeLogement.apiValue),
        MapEntry('ville', ville),
        MapEntry('quartier', quartier),
        MapEntry('surface', surface.toString()),
        MapEntry('prix_mois', prixMensuel.toString()),
        MapEntry('nombre_pieces', nombrePieces.toString()),
        if (latitude != null) MapEntry('latitude', latitude.toString()),
        if (longitude != null) MapEntry('longitude', longitude.toString()),
      ]);

      for (final equipement in equipements) {
        formData.fields.add(MapEntry('equipements[]', equipement.apiValue));
      }

      for (final photo in nouvellesPhotos) {
        formData.files.add(
          MapEntry(
            'photos[]',
            await MultipartFile.fromFile(photo.path, filename: photo.path.split('/').last),
          ),
        );
      }

      final response = await _api.raw.post('/annonces/$annonceId', data: formData);
      final rawData = response.data['data'] ?? response.data;
      return Annonce.fromJson(rawData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    } catch (e) {
      throw ApiException(
        message: "L'annonce a été mise à jour, mais la réponse du serveur n'a pas pu être lue correctement.",
      );
    }
  }

  Future<void> supprimerAnnonce(String annonceId) async {
    try {
      await _api.raw.delete('/annonces/$annonceId');
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}