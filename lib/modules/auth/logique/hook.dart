// lib/modules/auth/logique/hook.dart

import 'package:flutter/material.dart';
import '../data/depot.dart';
import '../data/user.dart';

class HookAuth extends ChangeNotifier {
  final DepotAuth _depot = DepotAuth();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters pour exposer les données proprement à l'UI
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tente de connecter l'utilisateur via le dépôt
  Future<bool> seConnecter(String telephone, String pin) async {
    _setLoading(true);
    _clearError();

    // Simulation d'un léger délai réseau pour l'effet visuel du loader
    await Future.delayed(const Duration(milliseconds: 600));

    final user = _depot.authentifier(telephone, pin);

    if (user != null) {
      _currentUser = user;
      _setLoading(false);
      return true; // Connexion réussie
    } else {
      _errorMessage = "Numéro ou code PIN incorrect.";
      _setLoading(false);
      return false; // Échec
    }
  }

  /// Gère l'inscription d'un nouvel utilisateur
  Future<bool> sinscrire({
    required String nom,
    required String prenom,
    required String telephone,
    required String boutique,
    required String adresse,
    required String ville,
    required String telBoutique,
    required String pin,
  }) async {
    _setLoading(true);
    _clearError();

    // Simulation d'un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    final nouvelUser = User(
      id: "ID-${DateTime.now().millisecondsSinceEpoch}",
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      role: 'admin',
      nomBoutique: boutique,
      adresse: adresse,
      ville: ville,
      telephoneBoutique: telBoutique,
      isFirstLogin: false,
    );

    final succes = _depot.enregistrerNouvelUtilisateur(nouvelUser, pin);

    if (succes) {
      _currentUser = nouvelUser;
      _setLoading(false);
      return true;
    } else {
      _errorMessage = "Ce numéro de téléphone est déjà utilisé.";
      _setLoading(false);
      return false;
    }
  }

  /// Force la modification du PIN pour les comptes temporaires
  Future<bool> modifierPremierPin(String nouveauPin) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 600));

    final succes = _depot.mettreAJourPin(_currentUser!.telephone, nouveauPin);

    if (succes) {
      // On récupère le profil mis à jour (isFirstLogin est maintenant false)
      _currentUser = _depot.authentifier(_currentUser!.telephone, nouveauPin);
      _setLoading(false);
      return true;
    } else {
      _errorMessage = "Une erreur est survenue lors de la mise à jour.";
      _setLoading(false);
      return false;
    }
  }

  /// Déconnexion
  void deconnecter() {
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  // Outils internes pour éviter la répétition de code
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}