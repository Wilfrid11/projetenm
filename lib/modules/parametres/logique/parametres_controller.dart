import 'package:flutter/material.dart';

import '../../auth/data/user.dart';
import '../../auth/logique/password_utils.dart';
import '../data/depot_parametres_firebase.dart';

class ParametresController extends ChangeNotifier {
  final DepotParametresFirebase _depot;
  User _user;
  bool _isLoading = false;
  String? _erreur;

  ParametresController({
    required User user,
    DepotParametresFirebase? depot,
  })  : _user = user,
        _depot = depot ?? DepotParametresFirebase();

  User get user => _user;
  bool get isLoading => _isLoading;
  String? get erreur => _erreur;

  Future<AbonnementBoutique> chargerAbonnement() {
    return _depot.chargerAbonnement(_user.boutiqueId);
  }

  Future<bool> modifierInfosPersonnelles({
    required String nom,
    required String prenom,
  }) async {
    if (nom.trim().isEmpty || prenom.trim().isEmpty) {
      _erreur = "Nom et prenom sont obligatoires.";
      notifyListeners();
      return false;
    }

    return _executer(() async {
      _user = await _depot.modifierInfosPersonnelles(
        user: _user,
        nom: nom.trim(),
        prenom: prenom.trim(),
      );
    });
  }

  Future<bool> modifierInfosBoutique({
    required String nomBoutique,
    required String adresse,
    required String ville,
    required String telephoneBoutique,
  }) async {
    if (nomBoutique.trim().isEmpty || ville.trim().isEmpty) {
      _erreur = "Nom de boutique et ville sont obligatoires.";
      notifyListeners();
      return false;
    }

    return _executer(() async {
      _user = await _depot.modifierInfosBoutique(
        user: _user,
        nomBoutique: nomBoutique.trim(),
        adresse: adresse.trim(),
        ville: ville.trim(),
        telephoneBoutique: telephoneBoutique.trim(),
      );
    });
  }

  Future<bool> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
    required String confirmation,
  }) async {
    if (!motDePasseSixChiffresValide(ancienMotDePasse) ||
        !motDePasseSixChiffresValide(nouveauMotDePasse)) {
      _erreur = "Les mots de passe doivent contenir 6 chiffres.";
      notifyListeners();
      return false;
    }

    if (nouveauMotDePasse != confirmation) {
      _erreur = "La confirmation ne correspond pas.";
      notifyListeners();
      return false;
    }

    return _executer(() async {
      await _depot.changerMotDePasse(
        user: _user,
        ancienMotDePasse: ancienMotDePasse,
        nouveauMotDePasse: nouveauMotDePasse,
      );
    });
  }

  Future<bool> _executer(Future<void> Function() action) async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _erreur = "Operation impossible pour le moment.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
