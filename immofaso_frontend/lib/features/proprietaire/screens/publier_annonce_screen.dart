import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/annonce_model.dart';
import '../providers/proprietaire_providers.dart';
import '../widgets/proprietaire_golden_button.dart';

/// Écran "NouvellesAnnonces" de la maquette. Sert à la fois pour publier
/// une nouvelle annonce et pour en modifier une existante (si
/// [annonceExistante] est fourni).
class PublierAnnonceScreen extends ConsumerStatefulWidget {
  const PublierAnnonceScreen({super.key, this.annonceExistante});

  final Annonce? annonceExistante;

  bool get isEdition => annonceExistante != null;

  @override
  ConsumerState<PublierAnnonceScreen> createState() => _PublierAnnonceScreenState();
}

class _PublierAnnonceScreenState extends ConsumerState<PublierAnnonceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _villeQuartierController = TextEditingController();
  final _budgetController = TextEditingController();
  final _piecesController = TextEditingController();
  final _surfaceController = TextEditingController();

  TypeLogement _typeLogement = TypeLogement.villa;
  final Set<Equipement> _equipements = {};
  final List<File> _nouvellesPhotos = [];

  double? _latitude;
  double? _longitude;
  bool _isLocalisationEnCours = false;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    final annonce = widget.annonceExistante;
    if (annonce != null) {
      _titreController.text = annonce.titre;
      _descriptionController.text = annonce.description;
      _villeQuartierController.text = '${annonce.quartier}, ${annonce.ville}';
      _budgetController.text = annonce.prixMensuel.toStringAsFixed(0);
      _piecesController.text = annonce.nombrePieces.toString();
      _surfaceController.text = annonce.surface.toString();
      _typeLogement = annonce.typeLogement;
      _equipements.addAll(annonce.equipements);
      _latitude = annonce.latitude;
      _longitude = annonce.longitude;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _villeQuartierController.dispose();
    _budgetController.dispose();
    _piecesController.dispose();
    super.dispose();
  }

  Future<void> _obtenirGeolocalisation() async {
    setState(() => _isLocalisationEnCours = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw "Activez la localisation dans les paramètres de l'appareil.";
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw "Autorisation de localisation refusée.";
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLocalisationEnCours = false);
    }
  }

  Future<void> _choisirImages() async {
    final images = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;
    setState(() => _nouvellesPhotos.addAll(images.map((x) => File(x.path))));
  }

  Future<void> _publier() async {
    if (!_formKey.currentState!.validate()) return;

    // "Ville, quartier" est saisi en un seul champ sur la maquette ; on le
    // sépare en `quartier, ville` pour correspondre au modèle de données.
    final parts = _villeQuartierController.text.split(',').map((p) => p.trim()).toList();
    final quartier = parts.isNotEmpty ? parts.first : _villeQuartierController.text.trim();
    final ville = parts.length > 1 ? parts.sublist(1).join(', ') : 'Bobo-Dioulasso';

    setState(() => _isPublishing = true);
    try {
      final repository = ref.read(proprietaireRepositoryProvider);
      if (widget.isEdition) {
        await repository.modifierAnnonce(
          annonceId: widget.annonceExistante!.id,
          titre: _titreController.text.trim(),
          description: _descriptionController.text.trim(),
          typeLogement: _typeLogement,
          ville: ville,
          quartier: quartier,
          surface: num.tryParse(_surfaceController.text) ?? 0,
          prixMensuel: num.tryParse(_budgetController.text) ?? 0,
          nombrePieces: int.tryParse(_piecesController.text) ?? 0,
          equipements: _equipements.toList(),
          latitude: _latitude,
          longitude: _longitude,
          nouvellesPhotos: _nouvellesPhotos,
        );
      } else {
        await repository.publierAnnonce(
          titre: _titreController.text.trim(),
          description: _descriptionController.text.trim(),
          typeLogement: _typeLogement,
          ville: ville,
          quartier: quartier,
          surface: num.tryParse(_surfaceController.text) ?? 0,
          prixMensuel: num.tryParse(_budgetController.text) ?? 0,
          nombrePieces: int.tryParse(_piecesController.text) ?? 0,
          equipements: _equipements.toList(),
          latitude: _latitude,
          longitude: _longitude,
          photos: _nouvellesPhotos,
        );
      }
      ref.invalidate(mesAnnoncesProvider);
      ref.invalidate(dashboardStatsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdition ? 'Annonce mise à jour.' : 'Annonce publiée, en attente de validation.'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La publication a échoué. Réessayez."), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.isEdition ? "Modifier l'annonce" : 'Annonce', style: const TextStyle(fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel("Titre de l'annonce"),
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(hintText: 'Ex: Studio meublé, Villa 3 pièces...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Décrivez le logement...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Ville, quartier'),
              ProprietaireGoldenField(
                hint: 'Ville, quartier',
                controller: _villeQuartierController,
                icon: Icons.location_on_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Surface'),
              ProprietaireGoldenField(
                hint: 'Surface',
                controller: _surfaceController,
                icon: Icons.rule_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || num.tryParse(v) == null) ? 'Surface invalide' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Type de logement'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TypeLogement.values.map((type) {
                  final isSelected = _typeLogement == type;
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _typeLogement = type),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              _FieldLabel('Nombre de pièces'),
              TextFormField(
                controller: _piecesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Ex: 3'),
                validator: (v) => (v == null || int.tryParse(v) == null) ? 'Nombre invalide' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Budget mensuel'),
              ProprietaireGoldenField(
                hint: 'Budget mensuel',
                controller: _budgetController,
                icon: Icons.search,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || num.tryParse(v) == null) ? 'Montant invalide' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Équipements'),
              ...Equipement.values.map((equipement) {
                return CheckboxListTile(
                  value: _equipements.contains(equipement),
                  onChanged: (checked) => setState(() {
                    checked == true ? _equipements.add(equipement) : _equipements.remove(equipement);
                  }),
                  title: Text(equipement.label),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                );
              }),
              const SizedBox(height: 12),
              ProprietaireGoldenButton(
                icon: Icons.location_on,
                label: _latitude != null
                    ? 'Position obtenue (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})'
                    : 'Obtenir la géolocalisation',
                isLoading: _isLocalisationEnCours,
                onTap: _obtenirGeolocalisation,
              ),
              const SizedBox(height: 12),
              ProprietaireGoldenButton(
                icon: Icons.image_outlined,
                label: 'Upload les images',
                onTap: _choisirImages,
              ),
              if (_nouvellesPhotos.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _nouvellesPhotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final file = _nouvellesPhotos[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(file, width: 76, height: 76, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _nouvellesPhotos.removeAt(index)),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _publier,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 212, 131, 25)),
                  child: _isPublishing
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.isEdition ? 'Enregistrer' : 'Publier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}