// lib/coeur/composants/btn_principal.dart

import 'package:flutter/material.dart'; // Pour utiliser les couleurs et styles définis dans notre thème global
import '../theme/theme_quinca.dart';

class BtnPrincipal extends StatelessWidget {
  final String texte;          // Le texte affiché sur le bouton (ex: "Se connecter")
  final VoidCallback onPressed; // L'action à faire quand on clique
  final bool isLoading;        // Si vrai, affiche un petit cercle qui tourne au lieu du texte
  final Color couleur;         // Permet de changer la couleur (ex: succes, alerte)

  const BtnPrincipal({
    super.key,
    required this.texte,
    required this.onPressed,
    this.isLoading = false,
    this.couleur = ThemeQuinca.bleuPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Le bouton prend toute la largeur de l'écran
      height: 56,             // Hauteur fixe pour être facile à toucher
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Désactivé si on charge
        style: ElevatedButton.styleFrom(
          backgroundColor: couleur,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24, 
                width: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : Text(texte, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}