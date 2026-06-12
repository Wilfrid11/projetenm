// lib/modules/auth/data/depot.dart

import 'mock.dart';
import 'user.dart';

class DepotAuth {
  // Simule la base de données dynamique en mémoire pour pouvoir modifier le PIN d'Amos
  final Map<String, String> _credentialsDB = Map.from(mockCredentials);
  final Map<String, User> _usersDB = Map.from(mockUsers);

  /// Vérifie les identifiants et retourne l'utilisateur si OK, sinon null
  User? authentifier(String telephone, String pin) {
    // Standardisation du numéro au format international attendu (+229...)
    final numeroComplet = telephone.startsWith('+') ? telephone : '+229$telephone';

    if (_credentialsDB.containsKey(numeroComplet) && _credentialsDB[numeroComplet] == pin) {
      return _usersDB[numeroComplet];
    }
    return null;
  }

  /// Enregistre un nouvel utilisateur dans la base locale (mémoire vive)
  bool enregistrerNouvelUtilisateur(User user, String pin) {
    final numeroComplet = user.telephone.startsWith('+') ? user.telephone : '+229${user.telephone}';
    
    if (_usersDB.containsKey(numeroComplet)) return false; // Le compte existe déjà

    _usersDB[numeroComplet] = user;
    _credentialsDB[numeroComplet] = pin;
    return true;
  }

  /// Met à jour le PIN du gérant et désactive le drapeau de premier login
  bool mettreAJourPin(String telephone, String nouveauPin) {
    final numeroComplet = telephone.startsWith('+') ? telephone : '+229$telephone';

    if (_usersDB.containsKey(numeroComplet)) {
      // 1. Mise à jour du mot de passe
      _credentialsDB[numeroComplet] = nouveauPin;

      // 2. Création d'une nouvelle instance utilisateur avec isFirstLogin à false
      final ancienUser = _usersDB[numeroComplet]!;
      _usersDB[numeroComplet] = User(
        id: ancienUser.id,
        nom: ancienUser.nom,
        prenom: ancienUser.prenom,
        ville: ancienUser.ville,
        telephone: ancienUser.telephone,
        role: ancienUser.role,
        nomBoutique: ancienUser.nomBoutique,
        telephoneBoutique: ancienUser.telephoneBoutique, // Ajout du paramètre 'telephoneBoutique'
        adresse: ancienUser.adresse, // Ajout du paramètre 'adresse'
        boutiqueId: ancienUser.boutiqueId,
        isFirstLogin: false, // Sécurité levée !
      );
      
      return true;
    }
    return false;
  }
}