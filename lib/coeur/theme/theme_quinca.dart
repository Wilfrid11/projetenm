// lib/core/theme/theme_quinca.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeQuinca {
  // Couleurs principales de la charte graphique
  static const Color bleuPrincipal = Color(0xFF1A3B8B);
  static const Color fondGris = Color(0xFFF8FAFC);
  static const Color bordure = Color(0xFFE2E8F0);

  // Couleurs de texte pour une belle hiérarchie
  static const Color texteFonce = Color(0xFF0F172A);      // Pour les titres et noms de produits
  static const Color texteSecondaire = Color(0xFF64748B); // Pour les sous-titres et références
  static const Color texteInverse = Colors.white;         // Pour les textes sur fond bleu

  // Couleurs de statut pour la gestion des stocks sur le terrain
  static const Color succes = Color(0xFF22C55E);  // Vert : Stock suffisant
  static const Color alerte = Color(0xFFF97316);  // Orange : Seuil critique atteint
  static const Color rupture = Color(0xFFEF4444); // Rouge : Plus de marchandise

  // --- Variables de Styles Réutilisables ---

  // Style des titres (Urbanist Bold)
  static TextStyle titrePrincipal = GoogleFonts.urbanist(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: texteFonce,
  );

  // Style des sous-titres ou labels (Inter)
  static TextStyle corpsTexte = GoogleFonts.inter(
    fontSize: 14,
    color: texteSecondaire,
  );

  // Décoration globale des Inputs (TextFormField)
  // On peut l'utiliser directement dans le ThemeData global ou manuellement
  static InputDecoration inputDecoration({required String label, required IconData icone}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: texteSecondaire, fontSize: 14),
      prefixIcon: Icon(icone, color: bleuPrincipal),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: bordure),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: bordure),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: bleuPrincipal, width: 2),
      ),
    );
  }
}