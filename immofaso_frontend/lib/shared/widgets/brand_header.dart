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
          const Image(
            image: AssetImage('assets/icons/icon2.png'),
            width: 80,
            height: 80,
          ),
          const SizedBox(width: 2),
          const Text(
            'ImmoFaso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 27, 27, 27),
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
