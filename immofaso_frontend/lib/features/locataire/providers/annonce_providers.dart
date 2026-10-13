import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/annonce_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/annonce_repository.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:latlong2/latlong.dart';

final annonceRepositoryProvider = Provider<AnnonceRepository>((ref) {
  return AnnonceRepository(apiClient: ref.watch(apiClientProvider));
});

/// État courant du formulaire de filtres (persiste tant que l'utilisateur
/// navigue entre l'accueil, l'onglet Recherche et l'écran Filtres).
class FiltresController extends Notifier<RechercheFiltres> {
  @override
  RechercheFiltres build() => const RechercheFiltres();

  void setVilleOuQuartier(String? value) {
    state = (value == null || value.isEmpty)
        ? state.copyWith(clearVilleOuQuartier: true)
        : state.copyWith(villeOuQuartier: value);
  }

  void setTypeLogement(TypeLogement? value) {
    state = value == null
        ? state.copyWith(clearTypeLogement: true)
        : state.copyWith(typeLogement: value);
  }

  void setBudgetMax(num? value) {
    state = value == null
        ? state.copyWith(clearBudgetMax: true)
        : state.copyWith(budgetMax: value);
  }

  void toggleEquipement(Equipement equipement) {
    final current = List<Equipement>.from(state.equipements);
    if (current.contains(equipement)) {
      current.remove(equipement);
    } else {
      current.add(equipement);
    }
    state = state.copyWith(equipements: current);
  }

  void reinitialiser() {
    state = const RechercheFiltres();
  }
}

final filtresControllerProvider =
    NotifierProvider<FiltresController, RechercheFiltres>(FiltresController.new);

/// Résultats de recherche pour les filtres actuellement sélectionnés.
/// Se relance automatiquement à chaque changement de [filtresControllerProvider].
final resultatsRechercheProvider = FutureProvider.autoDispose<List<Annonce>>((ref) async {
  final filtres = ref.watch(filtresControllerProvider);
  final repository = ref.watch(annonceRepositoryProvider);
  return repository.rechercher(filtres);
});

/// Détail d'une annonce, par id.
final annonceDetailProvider =
    FutureProvider.autoDispose.family<Annonce, String>((ref, annonceId) async {
  final repository = ref.watch(annonceRepositoryProvider);
  return repository.getDetail(annonceId);
});

/// Annonces avec coordonnées GPS, pour la carte (rayon autour de
/// Bobo-Dioulasso par défaut tant qu'on n'a pas la position réelle).
/// Position du locataire. null si la localisation est refusée ou désactivée.
final positionLocataireProvider = FutureProvider<LatLng?>((ref) async {
  if (!await Geolocator.isLocationServiceEnabled()) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  try {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LatLng(p.latitude, p.longitude);
  } catch (_) {
    return null;
  }
});

/// Annonces autour d'un point (lat, lng).
final annoncesNearbyProvider =
    FutureProvider.family<List<Annonce>, ({double lat, double lng})>(
  (ref, pos) => ref
      .watch(annonceRepositoryProvider)
      .annoncesNearby(lat: pos.lat, lng: pos.lng),
);

final favorisProvider = FutureProvider.autoDispose<List<Annonce>>((ref) async {
  final repository = ref.watch(annonceRepositoryProvider);
  return repository.getFavoris();
});