// lib/modules/produit/presentation/composants/carte_produit.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../coeur/theme/theme_quinca.dart';
import '../data/produit.dart';

class CarteProduit extends StatelessWidget {
  final Produit produit;
  final bool afficherDetailsCatalogue; // <-- Étape 1 : Déclarer la variable

  const CarteProduit({
    super.key,
    required this.produit,
    this.afficherDetailsCatalogue = false, // <-- Étape 2 : L'ajouter au constructeur avec une valeur par défaut
  });

  @override
  Widget build(BuildContext context) {
    Color couleurStatut;
    String texteStatut;

    // Logique des couleurs de statut selon l'état des stocks
    if (produit.quantite <= 0) {
      couleurStatut = ThemeQuinca.rupture;
      texteStatut = "Rupture";
    } else if (produit.quantite <= produit.seuilAlerte) {
      couleurStatut = ThemeQuinca.alerte;
      texteStatut = "Alerte (${produit.quantite} ${produit.uniteVente})";
    } else {
      couleurStatut = ThemeQuinca.succes;
      texteStatut = "${produit.quantite} ${produit.uniteVente}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Informations textuelles du produit (gauche)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produit.nom,
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ThemeQuinca.texteFonce,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  produit.categorie,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: ThemeQuinca.texteSecondaire,
                  ),
                ),
              ],
            ),
          ),
          
          // Prix et Badge d'état (droite)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${produit.prixVente.toInt()} FCFA",
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ThemeQuinca.texteFonce,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // Utilisation de la méthode moderne withValues recommandée par Flutter
                  color: couleurStatut.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  texteStatut,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: couleurStatut,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
