import 'package:flutter/material.dart';
import '../widgets/locataire_bottom_nav_bar.dart';
import 'tabs/accueil_tab.dart';
import 'tabs/carte_tab.dart';
import 'tabs/message_tabs.dart';
import 'tabs/profil_tab.dart';
import 'tabs/recherche_tab.dart';

/// Remplace le placeholder de route /locataire. Gère les 5 onglets
/// (Accueil, Recherche, Carte, Messages, Profil) avec un IndexedStack
/// pour préserver l'état de chaque onglet en arrière-plan.
class LocataireShell extends StatefulWidget {
  const LocataireShell({super.key});

  @override
  State<LocataireShell> createState() => _LocataireShellState();
}

class _LocataireShellState extends State<LocataireShell> {
  int _currentIndex = 0;

  static const _tabs = [
    AccueilTab(),
    RechercheTab(),
    CarteTab(),
    MessagesTab(),
    ProfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: LocataireBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}