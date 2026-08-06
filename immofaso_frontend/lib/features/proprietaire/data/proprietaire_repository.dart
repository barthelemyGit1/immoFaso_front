import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/annonce_model.dart';
import '../../../shared/models/dashboard_stats_model.dart';

/// Regroupe les appels réseau propres à l'espace propriétaire.
/// Correspond aux endpoints CA-PROPRIETAIRE-xx / CA-ANNONCE-xx :
///   GET    /proprietaire/dashboard
///   GET    /proprietaire/annonces
///   POST   /annonces                    (multipart: champs + photos)
///   PATCH  /annonces/:id
///   DELETE /annonces/:id
class ProprietaireRepository {
  ProprietaireRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _api.raw.get('/proprietaire/dashboard');
      return DashboardStats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<List<Annonce>> getMesAnnonces() async {
    try {
      final response = await _api.raw.get('/proprietaire/annonces');
      final results = response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      return results.map((json) => Annonce.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Publie une nouvelle annonce. Envoi en multipart pour joindre les
  /// photos sélectionnées (cf. Upload S3/Cloudflare R2 côté back).
  Future<Annonce> publierAnnonce({
    required String titre,
    required String description,
    required TypeLogement typeLogement,
    required String ville,
    required String quartier,
    required num prixMensuel,
    required int nombrePieces,
    required List<Equipement> equipements,
    double? latitude,
    double? longitude,
    List<File> photos = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'titre': titre,
        'description': description,
        'typeLogement': typeLogement.apiValue,
        'ville': ville,
        'quartier': quartier,
        'prixMensuel': prixMensuel,
        'nombrePieces': nombrePieces,
        'equipements': equipements.map((e) => e.apiValue).join(','),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        for (final photo in photos)
          'photos': await MultipartFile.fromFile(photo.path, filename: photo.path.split('/').last),
      });
      final response = await _api.raw.post('/annonces', data: formData);
      return Annonce.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Annonce> modifierAnnonce({
    required String annonceId,
    required String titre,
    required String description,
    required TypeLogement typeLogement,
    required String ville,
    required String quartier,
    required num prixMensuel,
    required int nombrePieces,
    required List<Equipement> equipements,
    double? latitude,
    double? longitude,
    List<File> nouvellesPhotos = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'titre': titre,
        'description': description,
        'typeLogement': typeLogement.apiValue,
        'ville': ville,
        'quartier': quartier,
        'prixMensuel': prixMensuel,
        'nombrePieces': nombrePieces,
        'equipements': equipements.map((e) => e.apiValue).join(','),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        for (final photo in nouvellesPhotos)
          'photos': await MultipartFile.fromFile(photo.path, filename: photo.path.split('/').last),
      });
      final response = await _api.raw.patch('/annonces/$annonceId', data: formData);
      return Annonce.fromJson(response.data as Map<String, dynamic>);
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