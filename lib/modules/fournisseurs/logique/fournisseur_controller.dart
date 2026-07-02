import 'package:flutter/material.dart';

import '../data/depot_fournisseurs_firebase.dart';
import '../data/fournisseur.dart';

class FournisseurController extends ChangeNotifier {
  final DepotFournisseursFirebase _depot = DepotFournisseursFirebase();
  final List<Fournisseur> _fournisseurs = [];
  bool _isLoading = false;
  String? _erreur;

  List<Fournisseur> get fournisseurs => List.unmodifiable(_fournisseurs);
  bool get isLoading => _isLoading;
  String? get erreur => _erreur;

  Future<void> charger(String boutiqueId) async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      final data = await _depot.chargerFournisseurs(boutiqueId);
      _fournisseurs
        ..clear()
        ..addAll(data);
    } catch (_) {
      _erreur = "Impossible de charger les fournisseurs.";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> ajouter(Fournisseur fournisseur) async {
    try {
      final cree = await _depot.ajouterFournisseur(fournisseur);
      _fournisseurs.add(cree);
      _fournisseurs.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
      notifyListeners();
      return true;
    } catch (_) {
      _erreur = "Impossible d'ajouter le fournisseur.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> modifier(Fournisseur fournisseur) async {
    try {
      await _depot.modifierFournisseur(fournisseur);
      final index = _fournisseurs.indexWhere((f) => f.id == fournisseur.id);
      if (index != -1) _fournisseurs[index] = fournisseur;
      notifyListeners();
      return true;
    } catch (_) {
      _erreur = "Impossible de modifier le fournisseur.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> desactiver(Fournisseur fournisseur) async {
    try {
      await _depot.desactiverFournisseur(fournisseur);
      _fournisseurs.removeWhere((f) => f.id == fournisseur.id);
      notifyListeners();
      return true;
    } catch (_) {
      _erreur = "Impossible de desactiver le fournisseur.";
      notifyListeners();
      return false;
    }
  }
}
