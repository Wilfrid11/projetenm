// lib/modules/produit/logique/stock_controller.dart

import 'package:flutter/material.dart';
import '../data/produit.dart';
import '../../historique/data/historique_models.dart'; // ◄ ON IMPORTE NOS MODÈLES ICI

class StockController extends ChangeNotifier {
  String? _boutiqueId;
  String get boutiqueId => _boutiqueId!; // Expose boutiqueId

  /// Définit la boutique active (Appelé après la connexion)
  void initialiserBoutique(String id) => _boutiqueId = id;

  // La vraie liste des produits, vide au démarrage de l'application
  final List<Produit> _produits = [];

  // ◄ NOUVEAU : La liste qui va stocker l'historique des arrivages en mémoire
  final List<EntreeFournisseur> _historiqueEntrees = [];

  // Permet aux écrans de lire les produits
  List<Produit> get produits => _produits;

  // ◄ NOUVEAU : Permet à ton écran d'historique de lire les arrivages
  List<EntreeFournisseur> get historiqueEntrees => _historiqueEntrees;

  // Liste des articles en rupture totale (Quantité == 0)
  List<Produit> get produitsEnRupture => 
      _produits.where((p) => p.estEnRupture).toList();

  // Liste des articles en alerte (0 < Quantité <= seuil)
  List<Produit> get produitsEnAlerte => 
      _produits.where((p) => p.estEnAlerte).toList();

  // Liste combinée pour le dashboard Gérant (Ruptures + Alertes)
  List<Produit> get alertesCritiques => 
      _produits.where((p) => p.estEnRupture || p.estEnAlerte).toList();

  // 1. AJOUTER UN NOUVEAU PRODUIT
  void nouveauProduit(Produit produit) {
    _produits.add(produit);
    notifyListeners();
  }

  // 2. MODIFIER UN PRODUIT EXISTANT
  void modifierProduit(Produit produitModifie) {
    final index = _produits.indexWhere((p) => p.id == produitModifie.id);
    if (index != -1) {
      _produits[index] = produitModifie;
      notifyListeners();
    }
  }

  // 3. SUPPRIMER UN PRODUIT
  void supprimerProduit(String id) {
    _produits.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // 4. ENREGISTRER UN ARRIVAGE COMPLET (PLUSIEURS PRODUITS)
  void validerArrivage(EntreeFournisseur arrivage) {
    // On parcourt chaque ligne de l'arrivage pour mettre à jour les stocks physiques
    for (var ligne in arrivage.lignes) {
      final index = _produits.indexWhere((p) => p.nom == ligne.nomProduit);
      
      if (index != -1) {
        _produits[index].quantite += ligne.quantiteRecue;
      }
    }
    
    // On ajoute l'arrivage à l'historique
    _historiqueEntrees.insert(0, arrivage);
    notifyListeners();
  }

  // ◄ NOUVEAU : Fonction pour masquer visuellement une entrée de l'écran (Poubelle)
  void masquerEntreeDeLEcran(int index) {
    _historiqueEntrees.removeAt(index);
    notifyListeners();
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