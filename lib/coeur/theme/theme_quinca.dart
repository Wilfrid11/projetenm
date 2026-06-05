// lib/core/theme/theme_quinca.dart

import 'package:flutter/material.dart';

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
}