// lib/modules/historique/donnees/historique_models.dart

// =======================================================
// 1. MODÈLES POUR L'HISTORIQUE DES ENTRÉES (ARRIVAGES)
// =======================================================

/// Représente un produit précis reçu lors d'un arrivage
class LigneEntree {
  final String nomProduit;
  final String categorie;
  final int quantiteRecue; // Quantité brute entrée en stock

  LigneEntree({
    required this.nomProduit,
    required this.categorie,
    required this.quantiteRecue,
  });
}

/// Représente le bloc complet d'un arrivage fournisseur
class EntreeFournisseur {
  final String id;
  final String fournisseur;
  final String dateArrivage; // Date et heure de l'entrée
  final String auteur;       // Le gérant qui a validé
  final List<LigneEntree> lignes; // La liste des produits de cet arrivage

  EntreeFournisseur({
    required this.id,
    required this.fournisseur,
    required this.dateArrivage,
    required this.auteur,
    required this.lignes,
  });
}

// =======================================================
// 2. MODÈLES POUR L'HISTORIQUE DES VENTES (REGISTRE)
// =======================================================

/// Représente un article vendu dans un panier
class LigneVente {
  final String nomProduit;
  final String categorie;
  final int quantiteVendue;
  final double prixUnitaire;

  LigneVente({
    required this.nomProduit,
    required this.categorie,
    required this.quantiteVendue,
    required this.prixUnitaire,
  });
}

/// Représente une vente complète encaissée
class VenteRealisee {
  final String numRecu;
  final String dateVente;
  final String moyenPaiement; // Ex: Espèces, Momo (MTN)
  final List<LigneVente> panier; // Les articles achetés

  VenteRealisee({
    required this.numRecu,
    required this.dateVente,
    required this.moyenPaiement,
    required this.panier,
  });

  // Fonction d'aide pour calculer automatiquement le nombre total d'articles
  int get totalArticles => panier.fold(0, (sum, item) => sum + item.quantiteVendue);

  // Fonction d'aide pour calculer le montant total en FCFA de la vente
  double get montantTotal => panier.fold(0.0, (sum, item) => sum + (item.prixUnitaire * item.quantiteVendue));
}