// lib/modules/dashboard/logique/gerant_hook.dart

import 'package:flutter/material.dart';
import '../../auth/data/user.dart';
import '../../auth/data/mock.dart';
import '../data/stats_gerant.dart';
import '../data/mock_dashboard.dart';

class HookGerant extends ChangeNotifier {
  // SOURCE DE VÉRITÉ DE LA SESSION : On charge le gérant Amos AGBOSSOU par sa clé
  User _utilisateurConnecte = mockUsers["+22996000000"]!;

  // Données de statistiques initiales lues depuis le Mock JSON
  StatsGerant _stats = StatsGerant.fromJson(mockStatsGerant);

  // Getters pour l'interface graphique
  User get utilisateurConnecte => _utilisateurConnecte;
  StatsGerant get stats => _stats;

  /// Permet d'incrémenter les ventes en local pour tester la réactivité de l'UI
  void incrementerVentes() {
    _stats = StatsGerant(
      nombreVentesJour: _stats.nombreVentesJour + 1,
      articlesCritiques: _stats.articlesCritiques,
    );
    notifyListeners(); // Force l'interface d'Amos à se rafraîchir
  }

  /// Appelée par ton module d'authentification si la session change
  void definirUtilisateurConnecte(User user) {
    _utilisateurConnecte = user;
    notifyListeners();
  }
}