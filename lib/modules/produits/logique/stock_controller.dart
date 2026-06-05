// lib/modules/produit/logique/stock_controller.dart

import 'package:flutter/material.dart';
import '../data/produit.dart';

class StockController extends ChangeNotifier {
  // La vraie liste des produits, vide au démarrage de l'application
  final List<Produit> _produits = [];

  // Permet aux écrans de lire les produits
  List<Produit> get produits => _produits;

  // Liste des articles en alerte critique
  List<Produit> get alertesCritiques => 
      _produits.where((p) => p.quantite <= p.seuilAlerte).toList();

  // 1. AJOUTER UN NOUVEAU PRODUIT
  void nouveauProduit(Produit produit) {
    _produits.add(produit);
    notifyListeners();
  }

  // 2. ENREGISTRER UN ARRIVAGE (ENTRÉE DE STOCK)
  void incrementerStock(String produitId, int quantiteAjoutee) {
    final index = _produits.indexWhere((p) => p.id == produitId);
    if (index != -1) {
      _produits[index].quantite += quantiteAjoutee;
      notifyListeners();
    }
  }

  // 3. ENREGISTRER UNE VENTE (SORTIE DE STOCK SÉCURISÉE)
  bool decrementerStock(String produitId, int quantiteVendue) {
    final index = _produits.indexWhere((p) => p.id == produitId);
    
    if (index != -1) {
      final produit = _produits[index];
      if (produit.quantite >= quantiteVendue) {
        produit.quantite -= quantiteVendue;
        notifyListeners();
        return true; // Vente acceptée
      }
    }
    return false; // Échec : Stock insuffisant
  }

  // 4. AJUSTEMENT MANUEL (INVENTAIRE / CORRECTION)
  void modifierQuantiteManuelle(String produitId, int nouvelleQuantite) {
    final index = _produits.indexWhere((p) => p.id == produitId);
    if (index != -1) {
      _produits[index].quantite = nouvelleQuantite;
      notifyListeners();
    }
  }
}