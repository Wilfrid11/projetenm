// lib/modules/dashboard/logique/dashboard_hook.dart

import 'package:flutter/material.dart';
import '../../auth/data/user.dart';
import '../../auth/data/mock.dart';
import '../data/stats.dart';
import '../data/mock_dashboard.dart';

class HookDashboard extends ChangeNotifier {
  // SOURCE DE VÉRITÉ DE LA SESSION : Contient l'utilisateur connecté
  // Par défaut pour tes tests, on charge l'admin Kofi MENSAH
  User _utilisateurConnecte = mockUsers["+22997000000"]!;

  // Données financières converties automatiquement depuis le Mock JSON
  final StatsDashboard _statsAdmin = StatsDashboard.fromJson(mockStatsAdmin);

  // Getters pour distribuer les informations aux écrans
  User get utilisateurConnecte => _utilisateurConnecte;
  StatsDashboard get statsAdmin => _statsAdmin;

  /// Appelée par ton module de Connexion pour mettre à jour l'utilisateur actif
  void definirUtilisateurConnecte(User user) {
    _utilisateurConnecte = user;
    notifyListeners(); // Met à jour instantanément les profils sur l'UI
  }

  /// Zone de rafraîchissement lors de la connexion future à l'API Laravel
  /*
  Future<void> chargerDonneesApi() async {
    // final response = await http.get(Uri.parse('URL_API'));
    // _statsAdmin = StatsDashboard.fromJson(jsonDecode(response.body));
    // notifyListeners();
  }
  */
}
