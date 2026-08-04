import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/annonce_model.dart';

/// Regroupe les appels réseau liés aux annonces, côté locataire.
/// Correspond aux endpoints CA-ANNONCE-xx du contrat API :
///   GET  /annonces?q=&typeLogement=&budgetMax=&equipements=
///   GET  /annonces/:id
///   GET  /annonces/proches?lat=&lng=&rayon=      (pour la carte)
///   POST /favoris/:annonceId
///   DELETE /favoris/:annonceId
///   GET  /favoris
class AnnonceRepository {
  AnnonceRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<Annonce>> rechercher(RechercheFiltres filtres) async {
    try {
      final response = await _api.raw.get(
        '/annonces',
        queryParameters: filtres.toQueryParams(),
      );
      final results = response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      return results.map((json) => Annonce.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Annonce> getDetail(String annonceId) async {
    try {
      final response = await _api.raw.get('/annonces/$annonceId');
      return Annonce.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Annonces avec coordonnées GPS, pour l'affichage sur la carte
  /// (recherche géospatiale PostGIS côté back).
  Future<List<Annonce>> rechercherProches({
    required double latitude,
    required double longitude,
    double rayonKm = 10,
  }) async {
    try {
      final response = await _api.raw.get('/annonces/proches', queryParameters: {
        'lat': latitude,
        'lng': longitude,
        'rayon': rayonKm,
      });
      final results = response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      return results.map((json) => Annonce.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<void> toggleFavori(String annonceId, {required bool isFavori}) async {
    try {
      if (isFavori) {
        await _api.raw.post('/favoris/$annonceId');
      } else {
        await _api.raw.delete('/favoris/$annonceId');
      }
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<List<Annonce>> getFavoris() async {
    try {
      final response = await _api.raw.get('/favoris');
      final results = response.data['data'] as List<dynamic>? ?? response.data as List<dynamic>;
      return results.map((json) => Annonce.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}