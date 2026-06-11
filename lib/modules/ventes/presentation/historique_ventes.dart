// lib/modules/historique/presentation/historique_ventes.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../logique/vente_controller.dart';
import '../../historique/data/historique_models.dart';

class HistoriqueVentesPage extends StatelessWidget {
  final VenteController controller;

  const HistoriqueVentesPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        iconTheme: const IconThemeData(color: ThemeQuinca.texteInverse),
        title: Text(
          "Registre des Ventes",
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeQuinca.texteInverse,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final ventes = controller.historiqueVentes;

          // Si aucune vente n'a été encaissée à la caisse pour le moment
          if (ventes.isEmpty) {
            return Center(
              child: Text(
                "Aucune vente enregistrée pour le moment.",
                style: GoogleFonts.inter(
                  color: ThemeQuinca.texteSecondaire,
                  fontSize: 13,
                ),
              ),
            );
          }

          // Affichage du registre des ventes
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ventes.length,
            itemBuilder: (context, index) {
              final vente = ventes[index];
              final bool estMomo = vente.moyenPaiement.toLowerCase().contains(
                "momo",
              );

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: ThemeQuinca.bordure),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête de la carte : Reçu, Date, et Poubelle de masquage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vente.numRecu,
                                style: GoogleFonts.urbanist(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                vente.dateVente,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: ThemeQuinca.texteSecondaire,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            onPressed: () => controller.masquerVenteDeLEcran(index),
                          ),
                        ],
                      ),
                      const Divider(height: 12, color: ThemeQuinca.bordure),

                      // Corps de la carte : Moyen de paiement, totaux, et bouton d'inspection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge Moyen de paiement dynamique
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeQuinca.fondGris,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      estMomo
                                          ? Icons.phone_android
                                          : Icons.payments_outlined,
                                      size: 12,
                                      color: ThemeQuinca.bleuPrincipal,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      vente.moyenPaiement,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Articles : ${vente.totalArticles}",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: ThemeQuinca.texteSecondaire,
                                ),
                              ),
                              Text(
                                "${vente.montantTotal.toInt()} FCFA",
                                style: GoogleFonts.urbanist(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: ThemeQuinca.bleuPrincipal,
                                ),
                              ),
                            ],
                          ),

                          // Bouton d'inspection qui ouvre le bottom sheet du panier
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: ThemeQuinca.bleuPrincipal,
                            ),
                            onPressed: () =>
                                _ouvrirDetailsPanier(context, vente),
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 16,
                            ),
                            label: Text(
                              "Voir panier",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Feuille surgissante pour inspecter les articles du panier en détail
  void _ouvrirDetailsPanier(BuildContext context, VenteRealisee vente) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contenu du Panier",
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Rattaché au ${vente.numRecu}",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: ThemeQuinca.texteSecondaire,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: vente.panier.length,
                  itemBuilder: (context, idx) {
                    final item = vente.panier[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nomProduit,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                item.categorie,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: ThemeQuinca.texteSecondaire,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${(item.prixUnitaire * item.quantiteVendue).toInt()} FCFA",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${item.prixUnitaire.toInt()} F x ${item.quantiteVendue}",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: ThemeQuinca.texteSecondaire,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
