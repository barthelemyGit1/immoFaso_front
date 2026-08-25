import 'package:flutter/material.dart';

/// Barre de navigation basse propriétaire — 4 icônes, conforme à la
/// maquette : Accueil, Annonces (publier/gérer), Messages, Profil.
class ProprietaireBottomNavBar extends StatelessWidget {
  const ProprietaireBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItemData(icon: Icons.home_rounded, label: 'Accueil'),
    _NavItemData(icon: Icons.add_circle, label: 'Annonces'),
    _NavItemData(icon: Icons.chat_bubble_rounded, label: 'Messages'),
    _NavItemData(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDFAF2C),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (index) {
              final isActive = index == currentIndex;
              final item = _items[index];
              return InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: isActive
                            ? const Color(0xFF4E19D4)
                            : Colors.white,
                        size: 28,
                      ),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF4E19D4)
                              : Colors.white,
                          fontSize: 6,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
