// lib/modules/auth/data/depot.dart

import 'mock.dart';
import 'user.dart';
import '../logique/telephone_utils.dart';

class DepotAuth {
  static final Map<String, String> _credentialsDB = Map.from(mockCredentials);
  static final Map<String, User> _usersDB = Map.from(mockUsers);

  User? authentifier(String telephone, String motDePasse) {
    final numeroComplet = normaliserTelephoneBenin(telephone);

    if (_credentialsDB.containsKey(numeroComplet) &&
        _credentialsDB[numeroComplet] == motDePasse) {
      return _usersDB[numeroComplet];
    }

    return null;
  }

  bool enregistrerNouvelUtilisateur(User user, String motDePasse) {
    final numeroComplet = normaliserTelephoneBenin(user.telephone);

    if (_usersDB.containsKey(numeroComplet)) {
      return false;
    }

    _usersDB[numeroComplet] = _copierAvecTelephoneNormalise(user, numeroComplet);
    _credentialsDB[numeroComplet] = motDePasse;
    return true;
  }

  bool mettreAJourPin(String telephone, String nouveauMotDePasse) {
    return mettreAJourMotDePasse(telephone, nouveauMotDePasse);
  }

  bool mettreAJourMotDePasse(String telephone, String nouveauMotDePasse) {
    final numeroComplet = normaliserTelephoneBenin(telephone);

    if (!_usersDB.containsKey(numeroComplet)) {
      return false;
    }

    _credentialsDB[numeroComplet] = nouveauMotDePasse;

    final ancienUser = _usersDB[numeroComplet]!;
    _usersDB[numeroComplet] = User(
      id: ancienUser.id,
      nom: ancienUser.nom,
      prenom: ancienUser.prenom,
      ville: ancienUser.ville,
      telephone: ancienUser.telephone,
      role: ancienUser.role,
      nomBoutique: ancienUser.nomBoutique,
      telephoneBoutique: ancienUser.telephoneBoutique,
      adresse: ancienUser.adresse,
      boutiqueId: ancienUser.boutiqueId,
      actif: ancienUser.actif,
      mustChangePassword: false,
    );

    return true;
  }

  bool supprimerUtilisateur(String telephone) {
    final numeroComplet = normaliserTelephoneBenin(telephone);
    final userSupprime = _usersDB.remove(numeroComplet) != null;
    _credentialsDB.remove(numeroComplet);
    return userSupprime;
  }

  User _copierAvecTelephoneNormalise(User user, String telephone) {
    return User(
      id: user.id,
      nom: user.nom,
      prenom: user.prenom,
      telephone: telephone,
      role: user.role,
      boutiqueId: user.boutiqueId,
      nomBoutique: user.nomBoutique,
      adresse: user.adresse,
      ville: user.ville,
      telephoneBoutique: user.telephoneBoutique,
      actif: user.actif,
      mustChangePassword: user.mustChangePassword,
    );
  }
}
