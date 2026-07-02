// lib/modules/ventes/logique/vente_controller.dart

import 'package:flutter/material.dart';

import '../../historique/data/historique_models.dart';
import '../../produits/data/produit.dart';
import '../../produits/logique/stock_controller.dart';
import '../data/panier_item.dart';

class VenteController extends ChangeNotifier {
  final StockController stockController;
  final String boutiqueId;
  final List<PanierItem> _panier = [];
  final List<VenteRealisee> _historiqueVentes = [];

  VenteController({required this.stockController, required this.boutiqueId});

  List<PanierItem> get panier => _panier
      .where((item) => item.produit.boutiqueId == boutiqueId)
      .toList(growable: false);

  List<VenteRealisee> get historiqueVentes => _historiqueVentes
      .where((vente) => vente.boutiqueId == boutiqueId)
      .toList(growable: false);

  double get montantTotalGlobal {
    return panier.fold(0, (somme, item) => somme + item.montantTotal);
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

  bool validerLaVente(String moyenPaiement) {
    final panierValide = panier;
    if (panierValide.isEmpty) return false;

    final lignesHistorique = panierValide.map((item) {
      return LigneVente(
        nomProduit: item.produit.nom,
        categorie: item.produit.categorie,
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
    );

    for (final item in panierValide) {
      final succes = stockController.decrementerStock(
        item.produit.id,
        item.quantiteChoisie,
      );
      if (!succes) return false;
    }

    _historiqueVentes.insert(0, nouvelleVente);
    _panier.removeWhere((item) => item.produit.boutiqueId == boutiqueId);
    notifyListeners();
    return true;
  }

  void masquerVenteDeLEcran(int index) {
    final ventesVisibles = historiqueVentes;
    if (index < 0 || index >= ventesVisibles.length) return;

    final numRecu = ventesVisibles[index].numRecu;
    _historiqueVentes.removeWhere(
      (vente) => vente.numRecu == numRecu && vente.boutiqueId == boutiqueId,
    );
    notifyListeners();
  }
}
