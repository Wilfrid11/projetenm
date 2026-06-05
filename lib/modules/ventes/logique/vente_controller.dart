// lib/modules/vente/logique/vente_controller.dart

import 'package:flutter/material.dart';
import '../../produits/data/produit.dart';
import '../../produits/logique/stock_controller.dart';
import '../data/panier_item.dart';

class VenteController extends ChangeNotifier {
  final StockController stockController;
  final List<PanierItem> _panier = [];

  VenteController({required this.stockController});

  // Getter pour lire le panier depuis l'interface
  List<PanierItem> get panier => _panier;

  // Calcul du montant total global du panier
  double get montantTotalGlobal {
    return _panier.fold(0, (somme, item) => somme + item.montantTotal);
  }

  // Ajouter un produit au panier avec vérification humaine du stock
  bool ajouterAuPanier(Produit produit) {
    // 1. Vérifier s'il y a du stock disponible au total
    if (produit.quantite <= 0) return false;

    final index = _panier.indexWhere((item) => item.produit.id == produit.id);

    if (index != -1) {
      // Si le produit est déjà dans le panier, on vérifie si on peut en ajouter encore un
      if (_panier[index].quantiteChoisie < produit.quantite) {
        _panier[index].quantiteChoisie++;
        notifyListeners();
        return true;
      }
      return false; // Plus assez de stock physique pour en ajouter plus
    } else {
      // Premier ajout dans le panier
      _panier.add(PanierItem(produit: produit, quantiteChoisie: 1));
      notifyListeners();
      return true;
    }
  }

  // Diminuer la quantité ou retirer du panier
  void diminuerOuRetirer(Produit produit) {
    final index = _panier.indexWhere((item) => item.produit.id == produit.id);
    if (index != -1) {
      if (_panier[index].quantiteChoisie > 1) {
        _panier[index].quantiteChoisie--;
      } else {
        _panier.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Valider la vente : On décrémente définitivement le stock physique
  bool validerLaVente() {
    if (_panier.isEmpty) return false;

    // Décrémentation du stock pour chaque article vendu
    for (var item in _panier) {
      widgetStockDecrement(item.produit.id, item.quantiteChoisie);
    }

    // On vide le panier après encaissement réussi
    _panier.clear();
    notifyListeners();
    return true;
  }

  // Petite méthode interne pour faire le pont avec le StockController
  void widgetStockDecrement(String id, int qteVendue) {
    final index = stockController.produits.indexWhere((p) => p.id == id);
    if (index != -1) {
      stockController.produits[index].quantite -= qteVendue;
      stockController.notifyListeners(); // Force la mise à jour de l'écran Stock
    }
  }
}