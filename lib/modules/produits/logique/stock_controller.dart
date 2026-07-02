// lib/modules/produits/logique/stock_controller.dart

import 'dart:async';

import 'package:flutter/material.dart';

import '../../historique/data/historique_models.dart';
import '../data/depot_arrivages_firebase.dart';
import '../data/depot_produits_firebase.dart';
import '../data/produit.dart';

class StockController extends ChangeNotifier {
  String? _boutiqueId;
  final DepotProduitsFirebase _depotProduits = DepotProduitsFirebase();
  final DepotArrivagesFirebase _depotArrivages = DepotArrivagesFirebase();

  final List<Produit> _produits = [];
  final List<EntreeFournisseur> _historiqueEntrees = [];
  StreamSubscription<List<Produit>>? _produitsSubscription;
  StreamSubscription<List<EntreeFournisseur>>? _arrivagesSubscription;
  bool _chargementProduits = false;
  bool _chargementArrivages = false;
  String? _erreurProduits;
  String? _erreurArrivages;

  String get boutiqueId {
    final id = _boutiqueId;
    if (id == null) {
      throw StateError('La boutique active doit etre initialisee avant usage.');
    }
    return id;
  }

  bool get chargementProduits => _chargementProduits;
  bool get chargementArrivages => _chargementArrivages;
  String? get erreurProduits => _erreurProduits;
  String? get erreurArrivages => _erreurArrivages;

  void initialiserBoutique(String id) {
    _boutiqueId = id;
    _demarrerEcouteProduits(id);
    _demarrerEcouteArrivages(id);
    notifyListeners();
  }

  List<Produit> get produits =>
      _produits.where(_produitDeLaBoutiqueActive).toList(growable: false);

  List<EntreeFournisseur> get historiqueEntrees => _historiqueEntrees
      .where(_entreeDeLaBoutiqueActive)
      .toList(growable: false);

  List<Produit> get produitsEnRupture =>
      produits.where((p) => p.estEnRupture).toList(growable: false);

  List<Produit> get produitsEnAlerte =>
      produits.where((p) => p.estEnAlerte).toList(growable: false);

  List<Produit> get alertesCritiques => produits
      .where((p) => p.estEnRupture || p.estEnAlerte)
      .toList(growable: false);

  Future<bool> chargerProduits() async {
    final id = _boutiqueId;
    if (id == null) return false;

    _chargementProduits = true;
    _erreurProduits = null;
    notifyListeners();

    try {
      final produitsFirebase = await _depotProduits.chargerProduits(id);
      _produits
        ..removeWhere((p) => p.boutiqueId == id)
        ..addAll(produitsFirebase);
      _chargementProduits = false;
      notifyListeners();
      return true;
    } catch (_) {
      _chargementProduits = false;
      _erreurProduits = "Impossible de charger les produits.";
      notifyListeners();
      return false;
    }
  }

  void _demarrerEcouteProduits(String boutiqueId) {
    _produitsSubscription?.cancel();
    _chargementProduits = true;
    _erreurProduits = null;

    _produitsSubscription = _depotProduits.ecouterProduits(boutiqueId).listen(
      (produitsFirebase) {
        _produits
          ..removeWhere((p) => p.boutiqueId == boutiqueId)
          ..addAll(produitsFirebase);
        _chargementProduits = false;
        notifyListeners();
      },
      onError: (_) {
        _chargementProduits = false;
        _erreurProduits = "Impossible d'ecouter les produits.";
        notifyListeners();
      },
    );
  }

  Future<bool> chargerArrivages() async {
    final id = _boutiqueId;
    if (id == null) return false;

    _chargementArrivages = true;
    _erreurArrivages = null;
    notifyListeners();

    try {
      final arrivagesFirebase = await _depotArrivages.chargerArrivages(id);
      _historiqueEntrees
        ..removeWhere((entree) => entree.boutiqueId == id)
        ..addAll(arrivagesFirebase);
      _chargementArrivages = false;
      notifyListeners();
      return true;
    } catch (_) {
      _chargementArrivages = false;
      _erreurArrivages = "Impossible de charger les arrivages.";
      notifyListeners();
      return false;
    }
  }

  void _demarrerEcouteArrivages(String boutiqueId) {
    _arrivagesSubscription?.cancel();
    _chargementArrivages = true;
    _erreurArrivages = null;

    _arrivagesSubscription =
        _depotArrivages.ecouterArrivages(boutiqueId).listen(
      (arrivagesFirebase) {
        _historiqueEntrees
          ..removeWhere((entree) => entree.boutiqueId == boutiqueId)
          ..addAll(arrivagesFirebase);
        _chargementArrivages = false;
        notifyListeners();
      },
      onError: (_) {
        _chargementArrivages = false;
        _erreurArrivages = "Impossible d'ecouter les arrivages.";
        notifyListeners();
      },
    );
  }

  Future<bool> nouveauProduit(Produit produit) async {
    if (!_boutiqueActive(produit.boutiqueId)) return false;

    try {
      final produitCree = await _depotProduits.ajouterProduit(produit);
      _produits.add(produitCree);
      notifyListeners();
      return true;
    } catch (_) {
      _erreurProduits = "Impossible d'enregistrer le produit.";
      notifyListeners();
      return false;
    }
  }

  Future<int> ajouterProduits(List<Produit> produits) async {
    final produitsValides =
        produits.where((p) => _boutiqueActive(p.boutiqueId)).toList();
    if (produitsValides.isEmpty) return 0;

    try {
      final produitsCrees = await _depotProduits.ajouterProduits(produitsValides);
      _produits.addAll(produitsCrees);
      notifyListeners();
      return produitsCrees.length;
    } catch (_) {
      _erreurProduits = "Impossible d'enregistrer les produits.";
      notifyListeners();
      return 0;
    }
  }

  Future<bool> modifierProduit(Produit produitModifie) async {
    if (!_boutiqueActive(produitModifie.boutiqueId)) return false;

    final index = _produits.indexWhere(
      (p) => p.id == produitModifie.id && _boutiqueActive(p.boutiqueId),
    );

    if (index != -1) {
      try {
        await _depotProduits.modifierProduit(produitModifie);
        _produits[index] = produitModifie;
        notifyListeners();
        return true;
      } catch (_) {
        _erreurProduits = "Impossible de modifier le produit.";
        notifyListeners();
        return false;
      }
    }

    return false;
  }

  Future<bool> supprimerProduit(String id) async {
    final index = _produits.indexWhere(
      (p) => p.id == id && _boutiqueActive(p.boutiqueId),
    );
    if (index == -1) return false;

    final produit = _produits[index];
    try {
      // Suppression logique : le document reste dans Firestore pour préserver les historiques.
      await _depotProduits.desactiverProduit(produit);
      _produits.removeAt(index);
      notifyListeners();
      return true;
    } catch (_) {
      _erreurProduits = "Impossible de désactiver le produit.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> validerArrivage(EntreeFournisseur arrivage) async {
    if (!_boutiqueActive(arrivage.boutiqueId)) return false;

    try {
      final entreeCreee = await _depotArrivages.validerArrivage(arrivage);

      for (final ligne in entreeCreee.lignes) {
        final index = _produits.indexWhere(
          (p) => p.id == ligne.produitId && _boutiqueActive(p.boutiqueId),
        );

        if (index != -1) {
          _produits[index].quantite += ligne.quantiteRecue;
        }
      }

      _historiqueEntrees.insert(0, entreeCreee);
      notifyListeners();
      return true;
    } catch (_) {
      _erreurArrivages = "Impossible de valider l'arrivage.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> masquerEntreeDeLEcran(int index) async {
    final entreesVisibles = historiqueEntrees;
    if (index < 0 || index >= entreesVisibles.length) return false;

    final entree = entreesVisibles[index];
    try {
      await _depotArrivages.masquerArrivage(entree);
      _historiqueEntrees.removeWhere(
        (item) => item.id == entree.id && _boutiqueActive(item.boutiqueId),
      );
      notifyListeners();
      return true;
    } catch (_) {
      _erreurArrivages = "Impossible de masquer l'arrivage.";
      notifyListeners();
      return false;
    }
  }

  bool decrementerStock(String produitId, int quantiteVendue) {
    final index = _produits.indexWhere(
      (p) => p.id == produitId && _boutiqueActive(p.boutiqueId),
    );

    if (index == -1) return false;

    final produit = _produits[index];
    if (produit.quantite < quantiteVendue) return false;

    produit.quantite -= quantiteVendue;
    notifyListeners();
    return true;
  }

  void modifierQuantiteManuelle(String produitId, int nouvelleQuantite) {
    final index = _produits.indexWhere(
      (p) => p.id == produitId && _boutiqueActive(p.boutiqueId),
    );

    if (index != -1) {
      _produits[index].quantite = nouvelleQuantite;
      notifyListeners();
    }
  }

  bool _boutiqueActive(String boutiqueId) =>
      _boutiqueId != null && boutiqueId == _boutiqueId;

  bool _produitDeLaBoutiqueActive(Produit produit) =>
      _boutiqueActive(produit.boutiqueId);

  bool _entreeDeLaBoutiqueActive(EntreeFournisseur entree) =>
      _boutiqueActive(entree.boutiqueId);

  @override
  void dispose() {
    _produitsSubscription?.cancel();
    _arrivagesSubscription?.cancel();
    super.dispose();
  }
}
