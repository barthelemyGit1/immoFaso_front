import 'package:flutter/material.dart';

/// Champ de saisie à fond doré (style "Ville, quartier" / "Budget mensuel"
/// de la maquette "NouvellesAnnonces").
class ProprietaireGoldenField extends StatelessWidget {
  const ProprietaireGoldenField({
    super.key,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 212, 131, 25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Color(0xFF3A2A00), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6B4E00)),
          prefixIcon: Icon(icon, color: const Color(0xFF6B4E00)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }
}

/// Bouton d'action à fond doré ("Obtenir la géolocalisation" /
/// "Upload les images" de la maquette).
class ProprietaireGoldenButton extends StatelessWidget {
  const ProprietaireGoldenButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0B429),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Row(
            children: [
              isLoading
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3A2A00)))
                  : Icon(icon, color: const Color(0xFF3A2A00)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Color(0xFF3A2A00), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}