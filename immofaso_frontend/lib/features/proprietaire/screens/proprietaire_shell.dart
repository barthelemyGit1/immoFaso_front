import 'package:flutter/material.dart';
import '../widgets/proprietaire_bottom_nav_bar.dart';
import 'tabs/accueil_proprietaire_tab.dart';
import 'tabs/mes_annonces_tab.dart';
import 'tabs/messages_proprietaire_tab.dart';
import 'tabs/profil_proprietaire_tab.dart';

/// Remplace le placeholder de route /proprietaire. Gère les 4 onglets
/// (Accueil, Annonces, Messages, Profil) avec un IndexedStack pour
/// préserver l'état de chaque onglet en arrière-plan.
class ProprietaireShell extends StatefulWidget {
  const ProprietaireShell({super.key});

  @override
  State<ProprietaireShell> createState() => _ProprietaireShellState();
}

class _ProprietaireShellState extends State<ProprietaireShell> {
  int _currentIndex = 0;

  static const _tabs = [
    AccueilProprietaireTab(),
    MesAnnoncesTab(),
    MessagesProprietaireTab(),
    ProfilProprietaireTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: ProprietaireBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
