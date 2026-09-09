import 'package:flutter/material.dart';

class AproposScreen extends StatelessWidget {
  const AproposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: const Center(
        child: Text('Contenu de l\'écran "À propos"'),
      ),
    );
  }
}