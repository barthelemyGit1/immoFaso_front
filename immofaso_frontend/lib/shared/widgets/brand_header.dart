import 'package:flutter/material.dart';

/// En-tête "logo + ImmoFaso" affiché en haut des écrans principaux
/// (accueil, recherche, carte...), conforme à la maquette Figma.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.home_rounded, color: Color.fromARGB(255, 212, 131, 25), size: 26),
          const SizedBox(width: 8),
          const Text(
            'ImmoFaso',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 27, 27, 27)),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}