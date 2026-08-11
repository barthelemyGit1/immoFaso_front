import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/annonce_model.dart';
import '../../../shared/models/dashboard_stats_model.dart';

class ProprietaireRepository {
  ProprietaireRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _api.raw.get('/annonces');
      return DashboardStats.fromJson(response.data as Map<String, dynamic>);
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

      // 1. Champs simples (Conversion explicite en String recommandée pour FormData)
      formData.fields.addAll([
        MapEntry('titre', titre),
        MapEntry('description', description),
        MapEntry('type_logement', typeLogement.apiValue.toLowerCase()),
        MapEntry('ville', ville),
        MapEntry('quartier', quartier),
        MapEntry('surface', surface.toString()),
        MapEntry('prix_mois', prixMensuel.toString()),
        MapEntry(
          'nombre_pieces',
          nombrePieces.toString(),
        ), // Attention à la convention snake_case de Laravel
        if (latitude != null) MapEntry('latitude', latitude.toString()),
        if (longitude != null) MapEntry('longitude', longitude.toString()),
      ]);

      // 2. Clés 'equipements[]' multiples pour que Laravel reconnaisse le tableau (Array)
      for (final equipement in equipements) {
        formData.fields.add(
          MapEntry('equipements[]', equipement.apiValue.toLowerCase()),
        );
      }

      // 3. Clés 'photos[]' multiples pour les fichiers
      for (final photo in photos) {
        formData.files.add(
          MapEntry(
            'photos[]',
            await MultipartFile.fromFile(
              photo.path,
              filename: photo.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _api.raw.post('/annonces', data: formData);
      final rawData = response.data['data'] ?? response.data;
      print("Réponse brute du serveur : ${response.data}");
      return Annonce.fromJson(rawData as Map<String, dynamic>);
    } on DioException catch (e, stacktrace) {
      //throw ApiClient.mapError(e);
      print(
        "Erreur exacte de parsing : $e",
      ); // <-- Affiche l'erreur Cast Exception exacte
      print(stacktrace);
      rethrow;
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

      // Note : Laravel a du mal à traiter les requêtes multipart/form-data natives sous PATCH.
      // Utiliser _method = PUT avec une requête POST résout ce problème.
      formData.fields.addAll([
        MapEntry('_method', 'PUT'),
        MapEntry('titre', titre),
        MapEntry('description', description),
        MapEntry('type_logement', typeLogement.apiValue.toLowerCase()),
        MapEntry('ville', ville),
        MapEntry('quartier', quartier),
        MapEntry('surface', surface.toString()),
        MapEntry('prix_mois', prixMensuel.toString()),
        MapEntry('nombre_pieces', nombrePieces.toString()),
        if (latitude != null) MapEntry('latitude', latitude.toString()),
        if (longitude != null) MapEntry('longitude', longitude.toString()),
      ]);

      for (final equipement in equipements) {
        formData.fields.add(
          MapEntry('equipements[]', equipement.apiValue.toLowerCase()),
        );
      }

      for (final photo in nouvellesPhotos) {
        formData.files.add(
          MapEntry(
            'photos[]',
            await MultipartFile.fromFile(
              photo.path,
              filename: photo.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _api.raw.post(
        '/annonces/$annonceId',
        data: formData,
      );
      final rawData = response.data['data'] ?? response.data;
      return Annonce.fromJson(rawData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
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
