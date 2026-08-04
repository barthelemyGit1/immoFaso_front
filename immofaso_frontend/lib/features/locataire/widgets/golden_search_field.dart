import 'package:flutter/material.dart';

/// Barre de recherche à fond doré, telle que sur l'écran d'accueil de
/// la maquette ("Ville, quartier, montant...").
class GoldenSearchField extends StatelessWidget {
  const GoldenSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
  });

  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0B429),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onTap: onTap,
        readOnly: readOnly,
        onChanged: onChanged,
        style: const TextStyle(color: Color(0xFF3A2A00), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6B4E00)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B4E00)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }
}