import 'package:flutter/material.dart';

/// Barre de navigation basse, dans le style de la maquette Figma :
/// fond rouge/terracotta, icône active en doré, icônes inactives en blanc.
class LocataireBottomNavBar extends StatelessWidget {
  const LocataireBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItemData(icon: Icons.home_rounded, label: 'Accueil'),
    _NavItemData(icon: Icons.search_rounded, label: 'Recherche'),
    _NavItemData(icon: Icons.map_rounded, label: 'Carte'),
    _NavItemData(icon: Icons.chat_bubble_rounded, label: 'Messages'),
    _NavItemData(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 212, 131, 25),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
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
                  child: Icon(
                    item.icon,
                    color: isActive ? const Color.fromARGB(255, 77, 34, 218) : Colors.white,
                    size: 26,
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