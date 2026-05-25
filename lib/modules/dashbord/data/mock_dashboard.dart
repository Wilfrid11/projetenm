// lib/modules/dashboard/data/mock_dashboard.dart
import 'package:flutter/material.dart';

/// 1. STATISTIQUES BRUTES DE L'ADMINISTRATEUR (Simule le JSON de l'API)
final Map<String, dynamic> mockStatsAdmin = {
  "total_ventes": 350000.0,
  "cout_achat": 265000.0, 
  "credits_dehors": 120000.0,
  "nombre_ruptures": 4,
};

/// 2. STATISTIQUES BRUTES DU GÉRANT
final Map<String, dynamic> mockStatsGerant = {
  "nombre_ventes_jour": 14,
  "articles_critiques": 7,
};

/// 3. LISTE DES ALERTES DE STOCK (PARTAGÉE ET DYNAMIQUE)
final List<Map<String, dynamic>> mockAlertesStock = [
  {
    "nom": "Ciment Bouclier 32.5",
    "statut": "Stock actuel : 0 sac",
    "label": "RUPTURE",
    "couleur": const Color(0xFFEF4444),
    "icone": Icons.cancel_outlined,
  },
  {
    "nom": "Fer 12mm — 6m",
    "statut": "8 barres restantes",
    "label": "CRITIQUE",
    "couleur": const Color(0xFFF59E0B),
    "icone": Icons.warning_amber_rounded,
  },
  {
    "nom": "Câble électrique 2.5mm",
    "statut": "15 m restants",
    "label": "CRITIQUE",
    "couleur": const Color(0xFFF59E0B),
    "icone": Icons.warning_amber_rounded,
  },
];