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
        nomComplet: ancienUser.nomComplet,
        telephone: ancienUser.telephone,
        role: ancienUser.role,
        nomBoutique: ancienUser.nomBoutique,
        isFirstLogin: false, // Sécurité levée !
      );
      
      return true;
    }
    return false;
  }
}