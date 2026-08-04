import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/annonce_model.dart';
import '../../providers/annonce_providers.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/golden_search_field.dart';
import '../resultats_recherche_screen.dart';

/// Écran "Filtrer" de la maquette, utilisé comme contenu de l'onglet
/// Recherche : critères puis lancement vers les résultats.
class RechercheTab extends ConsumerStatefulWidget {
  const RechercheTab({super.key});

  @override
  ConsumerState<RechercheTab> createState() => _RechercheTabState();
}

class _RechercheTabState extends ConsumerState<RechercheTab> {
  final _villeController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _villeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtres = ref.watch(filtresControllerProvider);
    final filtresNotifier = ref.read(filtresControllerProvider.notifier);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          BrandHeader(
            trailing: TextButton(
              onPressed: () {
                filtresNotifier.reinitialiser();
                _villeController.clear();
                _budgetController.clear();
              },
              child: const Text('Réinitialiser'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filtres', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),
                  Text('Ville, quartier', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  GoldenSearchField(
                    hint: 'Ville, quartier',
                    controller: _villeController,
                    onChanged: filtresNotifier.setVilleOuQuartier,
                  ),
                  const SizedBox(height: 20),
                  Text('Type de logement', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TypeLogement.values.map((type) {
                      final isSelected = filtres.typeLogement == type;
                      return ChoiceChip(
                        label: Text(type.label),
                        selected: isSelected,
                        onSelected: (_) => filtresNotifier.setTypeLogement(isSelected ? null : type),
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
                  const SizedBox(height: 20),
                  Text('Budget mensuel', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  GoldenSearchField(
                    hint: 'Budget mensuel (F CFA)',
                    controller: _budgetController,
                    onChanged: (value) => filtresNotifier.setBudgetMax(num.tryParse(value)),
                  ),
                  const SizedBox(height: 20),
                  Text('Équipements', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ...Equipement.values.map((equipement) {
                    return CheckboxListTile(
                      value: filtres.equipements.contains(equipement),
                      onChanged: (_) => filtresNotifier.toggleEquipement(equipement),
                      title: Text(equipement.label),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ResultatsRechercheScreen()),
              ),
              child: const Text('Lancer la recherche'),
            ),
          ),
        ],
      ),
    );
  }
}