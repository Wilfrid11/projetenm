// lib/modules/auth/logique/hook.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../data/depot_firebase.dart';
import '../data/user.dart';
import 'password_utils.dart';
import 'telephone_utils.dart';

class HookAuth extends ChangeNotifier {
  final DepotAuthFirebase _depot = DepotAuthFirebase();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters pour exposer les données proprement à l'UI
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tente de connecter l'utilisateur via le dépôt
  Future<bool> seConnecter(String telephone, String motDePasse) async {
    _setLoading(true);
    _clearError();

    if (!telephoneBeninValide(telephone) ||
        !motDePasseSixChiffresValide(motDePasse)) {
      _errorMessage = "Numéro ou mot de passe incorrect.";
      _setLoading(false);
      return false;
    }

    try {
      final user = await _depot.authentifier(telephone, motDePasse);

      if (user != null && user.actif) {
        _currentUser = user;
        _setLoading(false);
        return true;
      }

      _errorMessage = "Numéro ou mot de passe incorrect.";
      _setLoading(false);
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _messageErreurAuth(e);
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = "Connexion impossible pour le moment.";
      _setLoading(false);
      return false;
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
    required String motDePasse,
  }) async {
    _setLoading(true);
    _clearError();

    if (!telephoneBeninValide(telephone) ||
        !motDePasseSixChiffresValide(motDePasse)) {
      _errorMessage =
          "Le téléphone doit commencer par 01 et le mot de passe doit contenir 6 chiffres.";
      _setLoading(false);
      return false;
    }

    try {
      final user = await _depot.inscrireAdmin(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        nomBoutique: boutique,
        adresse: adresse,
        ville: ville,
        telephoneBoutique: telBoutique,
        motDePasse: motDePasse,
      );

      if (user == null) {
        _errorMessage = "Erreur d'inscription.";
        _setLoading(false);
        return false;
      }

      _currentUser = user;
      _setLoading(false);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _messageErreurAuth(e);
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = "Erreur d'inscription.";
      _setLoading(false);
      return false;
    }
  }

  /// Force la modification du mot de passe pour les comptes temporaires.
  Future<bool> modifierPremierPin(String nouveauMotDePasse) async {
    return changerMotDePasseObligatoire(nouveauMotDePasse);
  }

  Future<bool> changerMotDePasseObligatoire(String nouveauMotDePasse) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    if (!motDePasseSixChiffresValide(nouveauMotDePasse)) {
      _errorMessage = "Le mot de passe doit contenir 6 chiffres.";
      _setLoading(false);
      return false;
    }

    try {
      final succes = await _depot.changerMotDePasse(nouveauMotDePasse);

      if (!succes) {
        _errorMessage = "Une erreur est survenue lors de la mise à jour.";
        _setLoading(false);
        return false;
      }

      _currentUser = await _depot.chargerUtilisateur(_currentUser!.id);
      _setLoading(false);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _messageErreurAuth(e);
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = "Une erreur est survenue lors de la mise à jour.";
      _setLoading(false);
      return false;
    }
  }

  /// Déconnexion
  Future<void> deconnecter() async {
    await _depot.deconnecter();
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  void synchroniserUtilisateur(User user) {
    _currentUser = user;
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

  String _messageErreurAuth(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Ce numéro de téléphone est déjà utilisé.";
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return "Numéro ou mot de passe incorrect.";
      case 'weak-password':
        return "Le mot de passe doit contenir 6 chiffres.";
      case 'network-request-failed':
        return "Vérifiez votre connexion internet.";
      default:
        return "Erreur Firebase : ${e.code}";
    }
  }
}
