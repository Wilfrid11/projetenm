import 'package:flutter/material.dart';

class Produit {
  final String nom;
  final String reference;
  final String categorie;
  int quantite; // La quantité physique qui va bouger
  final double prixAchat;
  final double prixVente;
  final int seuilAlerte;

  Produit({
    required this.nom,
    required this.reference,
    required this.categorie,
    required this.quantite,
    required this.prixAchat,
    required this.prixVente,
    required this.seuilAlerte,
  });

  // Logique visuelle : définit la couleur selon le stock
  Color get couleurStatut {
    if (quantite <= 0) return Colors.red;
    if (quantite <= seuilAlerte) return Colors.orange;
    return Colors.green;
  }
}