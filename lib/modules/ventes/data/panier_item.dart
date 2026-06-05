// lib/modules/vente/data/panier_item.dart

import '../../produits/data/produit.dart';

class PanierItem {
  final Produit produit;
  int quantiteChoisie;

  PanierItem({
    required this.produit,
    required this.quantiteChoisie,
  });

  // Calcul humain du total pour cet article spécifique
  double get montantTotal => produit.prixVente * quantiteChoisie;
}