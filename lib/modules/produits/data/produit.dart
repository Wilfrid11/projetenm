// lib/modules/produit/data/produit.dart

class Produit {
  final String id;
  final String reference;
  final String nom;
  final String categorie;
  int quantite;
  final double prixAchat;
  final double prixVente;
  final int seuilAlerte;

  Produit({
    required this.id,
    required this.reference,
    required this.nom,
    required this.categorie,
    required this.quantite,
    required this.prixAchat,
    required this.prixVente,
    required this.seuilAlerte,
  });

  // Déjà ajouté au tour précédent
  bool get estEnRupture => quantite <= 0;

  // AJOUT : Permet à l'admin de compter les stocks faibles (en alerte mais pas encore épuisés)
  bool get estEnAlerte => quantite > 0 && quantite <= seuilAlerte;
}