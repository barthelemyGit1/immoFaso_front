import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// En-tête "logo + ImmoFaso" affiché en haut des écrans principaux.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.trailing});

  final Widget? trailing;

  static const _vertFonce = Color.fromARGB(255, 241, 238, 238);
  static const _vertClair = Color.fromARGB(255, 241, 239, 237);
  static const _jaune = Color(0xFF4E19D4);

  @override
  Widget build(BuildContext context) {
    // Le fond monte jusque sous la barre d'état.
    final top = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // icônes blanches dans la barre d'état
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, top + 8, 20, 6),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_vertFonce, _vertClair],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: IconTheme(
          // Les icônes passées dans `trailing` sont blanches par défaut.
          data: const IconThemeData(color: Colors.white),
          child: Row(
            children: [
              const Image(
                image: AssetImage('assets/icons/icon2.png'),
                width: 72,
                height: 72,
              ),
              const SizedBox(width: 6),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Immo',
                      style: TextStyle(color: Color.fromARGB(255, 11, 11, 11)),
                    ),
                    TextSpan(
                      text: 'Faso',
                      style: TextStyle(color: _jaune),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
