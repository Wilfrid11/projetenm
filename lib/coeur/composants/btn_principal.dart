// lib/coeur/composants/btn_principal.dart

import 'package:flutter/material.dart'; // Pour utiliser les couleurs et styles définis dans notre thème global

class BtnPrincipal extends StatelessWidget {
  final String texte;          // Le texte affiché sur le bouton (ex: "Se connecter")
  final VoidCallback onPressed; // L'action à faire quand on clique
  final bool isLoading;        // Si vrai, affiche un petit cercle qui tourne au lieu du texte

  const BtnPrincipal({
    super.key,
    required this.texte,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Le bouton prend toute la largeur de l'écran
      height: 56,             // Hauteur fixe pour être facile à toucher
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Désactivé si on charge
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white) // Petit cercle blanc
            : Text(texte),
      ),
    );
  }
}