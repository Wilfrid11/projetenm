// lib/modules/vente/logique/vente_controller.dart

import 'package:flutter/material.dart';
import '../../produits/data/produit.dart';
import '../../produits/logique/stock_controller.dart';
import '../data/panier_item.dart';
import '../../historique/data/historique_models.dart'; // ◄ ON IMPORTE NOS MODÈLES ICI

class VenteController extends ChangeNotifier {
  final StockController stockController;
  final String boutiqueId;
  final List<PanierItem> _panier = [];

  // ◄ NOUVEAU : La liste qui va retenir l'historique de tes ventes en mémoire vive
  final List<VenteRealisee> _historiqueVentes = [];

  VenteController({required this.stockController, required this.boutiqueId});

  // Getter pour lire le panier depuis l'interface
  List<PanierItem> get panier => _panier;

  // ◄ NOUVEAU : Permet à ton écran d'historique de lire le registre des ventes
  List<VenteRealisee> get historiqueVentes => _historiqueVentes;

  // Calcul du montant total global du panier
  double get montantTotalGlobal {
    return _panier.fold(0, (somme, item) => somme + item.montantTotal);
  }

  // Calcul du Chiffre d'Affaire (CA) du jour
  double get chiffreAffaireJour {
    final aujourdhui = DateTime.now();
    final dateStr = "${aujourdhui.day.toString().padLeft(2, '0')}/${aujourdhui.month.toString().padLeft(2, '0')}/${aujourdhui.year}";
    return _historiqueVentes
        .where((v) => v.dateVente.startsWith(dateStr))
        .fold(0.0, (sum, v) => sum + v.montantTotal);
  }

  // Calcul du Bénéfice net du jour
  double get beneficeJour {
    final aujourdhui = DateTime.now();
    final dateStr = "${aujourdhui.day.toString().padLeft(2, '0')}/${aujourdhui.month.toString().padLeft(2, '0')}/${aujourdhui.year}";
    
    double total = 0;
    final ventesDuJour = _historiqueVentes.where((v) => v.dateVente.startsWith(dateStr));
    for (var v in ventesDuJour) {
      for (var ligne in v.panier) {
        total += (ligne.prixUnitaire - ligne.prixAchat) * ligne.quantiteVendue;
      }
    }
    return total;
  }

  // Ajouter un produit au panier avec vérification humaine du stock
  bool ajouterAuPanier(Produit produit) {
    if (produit.quantite <= 0) return false;

    final index = _panier.indexWhere((item) => item.produit.id == produit.id);

    if (index != -1) {
      if (_panier[index].quantiteChoisie < produit.quantite) {
        _panier[index].quantiteChoisie++;
        notifyListeners();
        return true;
      }
      return false;
    } else {
      _panier.add(PanierItem(produit: produit, quantiteChoisie: 1));
      notifyListeners();
      return true;
    }
  }

  // Définit une quantité précise (pour l'appui long)
  bool definirQuantite(Produit produit, int quantite) {
    final index = _panier.indexWhere((item) => item.produit.id == produit.id);
    if (index != -1) {
      if (quantite <= 0) {
        _panier.removeAt(index);
      } else if (quantite <= produit.quantite) {
        _panier[index].quantiteChoisie = quantite;
      } else {
        return false; // Stock insuffisant
      }
      notifyListeners();
    }
    return true;
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

  // Valider la vente : MODIFIÉE pour accepter le moyen de paiement choisi à la caisse
  bool validerLaVente(String moyenPaiement) {
    if (_panier.isEmpty) return false;

    // 1. NOUVEAU : On convertit les éléments du panier actuel vers le format de l'historique
    final List<LigneVente> lignesHistorique = _panier.map((item) {
      return LigneVente(
        nomProduit: item.produit.nom,
        categorie: item.produit.categorie, // Assure-toi que ton modèle Produit a bien un champ categorie
        quantiteVendue: item.quantiteChoisie,
        prixUnitaire: item.produit.prixVente, // Assure-toi que c'est bien .prix (ou .prixVente selon ton modèle)
        prixAchat: item.produit.prixAchat,
      );
    }).toList();

    final maintenant = DateTime.now();
    final dateFormatee = "${maintenant.day.toString().padLeft(2, '0')}/${maintenant.month.toString().padLeft(2, '0')}/${maintenant.year}";

    // 2. NOUVEAU : On fabrique l'objet de vente complet avec un numéro de reçu unique
    final nouvelleVente = VenteRealisee(
      numRecu: "REC-${maintenant.millisecondsSinceEpoch.toString().substring(7)}",
      boutiqueId: boutiqueId,
      dateVente: "$dateFormatee à ${maintenant.hour}:${maintenant.minute.toString().padLeft(2, '0')}", 
      moyenPaiement: moyenPaiement, // "Espèces", "Momo (MTN)"... reçu depuis l'interface
      panier: lignesHistorique,
    );

    // 3. NOUVEAU : On pousse cette vente tout en haut de notre historique
    _historiqueVentes.insert(0, nouvelleVente);

    // 4. Décrémentation du stock pour chaque article vendu (Ton code d'origine)
    for (var item in _panier) {
      stockController.decrementerStock(item.produit.id, item.quantiteChoisie);
    }

    // 5. On vide le panier après encaissement réussi
    _panier.clear();
    notifyListeners(); // Met à jour la caisse ET le registre des ventes
    return true;
  }

  // ◄ NOUVEAU : Fonction pour nettoyer visuellement une vente du registre (Poubelle)
  void masquerVenteDeLEcran(int index) {
    _historiqueVentes.removeAt(index);
    notifyListeners();
  }
}