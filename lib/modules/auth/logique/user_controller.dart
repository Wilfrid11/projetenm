// lib/modules/auth/logique/user_controller.dart

import 'package:flutter/material.dart';
import '../data/depot_firebase.dart';
import '../data/user.dart';
import 'password_utils.dart';
import 'telephone_utils.dart';

class UserController extends ChangeNotifier {
  final DepotAuthFirebase _depot = DepotAuthFirebase();

  // Liste des utilisateurs gérés en mémoire (sera liée à l'API plus tard)
  final List<User> _utilisateurs = [];

  // Récupère uniquement les utilisateurs de la boutique actuelle
  List<User> utilisateursBoutique(String boutiqueId) {
    return _utilisateurs.where((u) => u.boutiqueId == boutiqueId).toList();
  }

  Future<void> chargerUtilisateursBoutique(String boutiqueId) async {
    final utilisateurs = await _depot.utilisateursBoutique(boutiqueId);
    _utilisateurs
      ..clear()
      ..addAll(utilisateurs);
    notifyListeners();
  }

  // Ajouter un nouveau gérant
  Future<String?> ajouterGerant(User user) async {
    final motDePasseTemporaire = genererMotDePasseTemporaire();
    final telephoneNormalise = normaliserTelephoneBenin(user.telephone);
    final gerant = User(
      id: user.id,
      nom: user.nom,
      prenom: user.prenom,
      telephone: telephoneNormalise,
      role: user.role,
      boutiqueId: user.boutiqueId,
      nomBoutique: user.nomBoutique,
      adresse: user.adresse,
      ville: user.ville,
      telephoneBoutique: user.telephoneBoutique,
      actif: true,
      mustChangePassword: true,
    );

    final gerantCree = await _depot.creerGerant(
      gerant: gerant,
      motDePasseTemporaire: motDePasseTemporaire,
    );

    if (gerantCree == null) {
      return null;
    }

    _utilisateurs.add(gerantCree);
    notifyListeners();
    return motDePasseTemporaire;
  }

  // Supprimer un accès
  Future<void> supprimerUtilisateur(String id) async {
    final index = _utilisateurs.indexWhere((u) => u.id == id);
    if (index == -1) {
      return;
    }

    final user = _utilisateurs[index];
    await _depot.supprimerUtilisateur(user);
    _utilisateurs.removeAt(index);
    notifyListeners();
  }
}
