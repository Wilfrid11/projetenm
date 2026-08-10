// lib/modules/ventes/logique/vente_controller.dart

import 'dart:async';

import 'package:flutter/material.dart';

import '../../historique/data/historique_models.dart';
import '../../produits/data/produit.dart';
import '../../produits/logique/stock_controller.dart';
import '../data/depot_ventes_firebase.dart';
import '../data/panier_item.dart';

class VenteController extends ChangeNotifier {
  final StockController stockController;
  final String boutiqueId;
  final DepotVentesFirebase _depotVentes = DepotVentesFirebase();
  final List<PanierItem> _panier = [];
  final List<VenteRealisee> _historiqueVentes = [];
  StreamSubscription<List<VenteRealisee>>? _ventesSubscription;
  bool _validationEnCours = false;
  String? _erreurVente;

  VenteController({required this.stockController, required this.boutiqueId}) {
    _ecouterVentes();
  }

  bool get validationEnCours => _validationEnCours;
  String? get erreurVente => _erreurVente;

  List<PanierItem> get panier => _panier
      .where((item) => item.produit.boutiqueId == boutiqueId)
      .toList(growable: false);

  List<VenteRealisee> get historiqueVentes => _historiqueVentes
      .where((vente) => vente.boutiqueId == boutiqueId)
      .toList(growable: false);

  double get montantTotalGlobal {
    return panier.fold(0, (somme, item) => somme + item.montantTotal);
  }

  int quantiteDansPanier(Produit produit) {
    final index = _panier.indexWhere(
      (item) =>
          item.produit.id == produit.id &&
          item.produit.boutiqueId == boutiqueId,
    );

    if (index == -1) return 0;
    return _panier[index].quantiteChoisie;
  }

  double get chiffreAffaireJour {
    final aujourdhui = DateTime.now();
    final dateStr =
        "${aujourdhui.day.toString().padLeft(2, '0')}/${aujourdhui.month.toString().padLeft(2, '0')}/${aujourdhui.year}";

    return historiqueVentes
        .where((v) => v.dateVente.startsWith(dateStr))
        .fold(0.0, (sum, v) => sum + v.montantTotal);
  }

  double get beneficeJour {
    final aujourdhui = DateTime.now();
    final dateStr =
        "${aujourdhui.day.toString().padLeft(2, '0')}/${aujourdhui.month.toString().padLeft(2, '0')}/${aujourdhui.year}";

    double total = 0;
    final ventesDuJour =
        historiqueVentes.where((v) => v.dateVente.startsWith(dateStr));

    for (final vente in ventesDuJour) {
      for (final ligne in vente.panier) {
        total += (ligne.prixUnitaire - ligne.prixAchat) * ligne.quantiteVendue;
      }
    }

    return total;
  }

  bool ajouterAuPanier(Produit produit) {
    if (produit.boutiqueId != boutiqueId || produit.quantite <= 0) {
      return false;
    }

    final index = _panier.indexWhere(
      (item) =>
          item.produit.id == produit.id &&
          item.produit.boutiqueId == boutiqueId,
    );

    if (index != -1) {
      if (_panier[index].quantiteChoisie >= produit.quantite) return false;

      _panier[index].quantiteChoisie++;
      notifyListeners();
      return true;
    }

    _panier.add(PanierItem(produit: produit, quantiteChoisie: 1));
    notifyListeners();
    return true;
  }

  bool ajouterQuantiteAuPanier(Produit produit, int quantite) {
    if (produit.boutiqueId != boutiqueId || produit.quantite <= 0) {
      return false;
    }

    if (quantite <= 0) return false;

    final index = _panier.indexWhere(
      (item) =>
          item.produit.id == produit.id &&
          item.produit.boutiqueId == boutiqueId,
    );

    final quantiteActuelle = index == -1 ? 0 : _panier[index].quantiteChoisie;
    final nouvelleQuantite = quantiteActuelle + quantite;

    if (nouvelleQuantite > produit.quantite) return false;

    if (index == -1) {
      _panier.add(PanierItem(produit: produit, quantiteChoisie: quantite));
    } else {
      _panier[index].quantiteChoisie = nouvelleQuantite;
    }

    notifyListeners();
    return true;
  }

  bool definirQuantite(Produit produit, int quantite) {
    if (produit.boutiqueId != boutiqueId) return false;

    final index = _panier.indexWhere(
      (item) =>
          item.produit.id == produit.id &&
          item.produit.boutiqueId == boutiqueId,
    );

    if (index == -1) return true;

    if (quantite <= 0) {
      _panier.removeAt(index);
    } else if (quantite <= produit.quantite) {
      _panier[index].quantiteChoisie = quantite;
    } else {
      return false;
    }

    notifyListeners();
    return true;
  }

  void diminuerOuRetirer(Produit produit) {
    if (produit.boutiqueId != boutiqueId) return;

    final index = _panier.indexWhere(
      (item) =>
          item.produit.id == produit.id &&
          item.produit.boutiqueId == boutiqueId,
    );

    if (index == -1) return;

    if (_panier[index].quantiteChoisie > 1) {
      _panier[index].quantiteChoisie--;
    } else {
      _panier.removeAt(index);
    }

    notifyListeners();
  }

  Future<bool> validerLaVente({
    required String moyenPaiement,
    required String vendeurId,
    required String vendeurNom,
    double? montantRecu,
    double? monnaieRendue,
    String? notePaiement,
  }) async {
    final panierValide = panier;
    if (panierValide.isEmpty) return false;

    final lignesHistorique = panierValide.map((item) {
      return LigneVente(
        produitId: item.produit.id,
        nomProduit: item.produit.nom,
        categorie: item.produit.categorie,
        uniteVente: item.produit.uniteVente,
        quantiteVendue: item.quantiteChoisie,
        prixUnitaire: item.produit.prixVente,
        prixAchat: item.produit.prixAchat,
      );
    }).toList();

    final maintenant = DateTime.now();
    final dateFormatee =
        "${maintenant.day.toString().padLeft(2, '0')}/${maintenant.month.toString().padLeft(2, '0')}/${maintenant.year}";

    final nouvelleVente = VenteRealisee(
      numRecu:
          "REC-${maintenant.millisecondsSinceEpoch.toString().substring(7)}",
      boutiqueId: boutiqueId,
      dateVente:
          "$dateFormatee a ${maintenant.hour}:${maintenant.minute.toString().padLeft(2, '0')}",
      moyenPaiement: moyenPaiement,
      panier: lignesHistorique,
      vendeurId: vendeurId,
      vendeurNom: vendeurNom,
      createdAt: maintenant,
      visible: true,
      montantRecu: montantRecu,
      monnaieRendue: monnaieRendue,
      notePaiement: notePaiement,
    );

    _validationEnCours = true;
    _erreurVente = null;
    notifyListeners();

    try {
      await _depotVentes.validerVente(nouvelleVente);
      _panier.removeWhere((item) => item.produit.boutiqueId == boutiqueId);
      _validationEnCours = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erreurVente = e is StateError
          ? e.message
          : "Impossible de valider la vente.";
      _validationEnCours = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> masquerVenteDeLEcran(int index) async {
    final ventesVisibles = historiqueVentes;
    if (index < 0 || index >= ventesVisibles.length) return false;

    final vente = ventesVisibles[index];
    try {
      await _depotVentes.masquerVente(vente);
      _historiqueVentes.removeWhere(
        (item) => item.id == vente.id && item.boutiqueId == boutiqueId,
      );
      notifyListeners();
      return true;
    } catch (_) {
      _erreurVente = "Impossible de masquer la vente.";
      notifyListeners();
      return false;
    }
  }

  void _ecouterVentes() {
    _ventesSubscription?.cancel();
    _ventesSubscription = _depotVentes.ecouterVentes(boutiqueId).listen(
      (ventesFirebase) {
        _historiqueVentes
          ..removeWhere((vente) => vente.boutiqueId == boutiqueId)
          ..addAll(ventesFirebase);
        notifyListeners();
      },
      onError: (_) {
        _erreurVente = "Impossible d'ecouter les ventes.";
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _ventesSubscription?.cancel();
    super.dispose();
  }
}
