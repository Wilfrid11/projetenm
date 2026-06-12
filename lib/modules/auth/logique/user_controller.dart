// lib/modules/auth/logique/user_controller.dart

import 'package:flutter/material.dart';
import '../data/user.dart';

class UserController extends ChangeNotifier {
  // Liste des utilisateurs gérés en mémoire (sera liée à l'API plus tard)
  final List<User> _utilisateurs = [];

  // Récupère uniquement les utilisateurs de la boutique actuelle
  List<User> utilisateursBoutique(String boutiqueId) {
    return _utilisateurs.where((u) => u.boutiqueId == boutiqueId).toList();
  }

  // Ajouter un nouveau gérant
  void ajouterGerant(User user) {
    _utilisateurs.add(user);
    notifyListeners();
  }

  // Supprimer un accès
  void supprimerUtilisateur(String id) {
    _utilisateurs.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}