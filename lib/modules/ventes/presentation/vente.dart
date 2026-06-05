// lib/modules/vente/presentation/vente.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../../coeur/composants/filtre.dart';
import '../logique/vente_controller.dart';

class VentePage extends StatefulWidget {
  final VenteController venteController;

  const VentePage({
    super.key,
    required this.venteController,
  });

  @override
  State<VentePage> createState() => _VentePageState();
}

class _VentePageState extends State<VentePage> {
  String _rechercheQuery = "";
  String _categorieSelectionnee = "Tout";

  @override
  Widget build(BuildContext context) {
    final largeEcran = MediaQuery.of(context).size.width > 800;

    return ListenableBuilder(
      listenable: widget.venteController,
      builder: (context, _) {
        final tousLesProduits = widget.venteController.stockController.produits;
        final panier = widget.venteController.panier;

        // CORRECTION ICI : "produitsFiltres" sans accent pour respecter le linter Dart
        final produitsFiltres = tousLesProduits.where((prod) {
          final correspondRecherche = prod.nom.toLowerCase().contains(_rechercheQuery.toLowerCase()) ||
              prod.reference.toLowerCase().contains(_rechercheQuery.toLowerCase());
          final correspondCategorie = _categorieSelectionnee == "Tout" || 
              prod.categorie.toLowerCase() == _categorieSelectionnee.toLowerCase();
          return correspondRecherche && correspondCategorie;
        }).toList();

        // Corps principal de la caisse
        Widget contenuCaisse = Column(
          children: [
            Filtre(
              categorieInitiale: _categorieSelectionnee,
              onRechercheChange: (valeur) => setState(() => _rechercheQuery = valeur),
              onCategorieChange: (cat) => setState(() => _categorieSelectionnee = cat),
            ),

            // Zone des produits disponibles
            Expanded(
              flex: 3,
              child: produitsFiltres.isEmpty
                  ? Center(child: Text("Aucun produit disponible", style: GoogleFonts.inter(color: ThemeQuinca.texteSecondaire)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: produitsFiltres.length,
                      itemBuilder: (context, index) {
                        final prod = produitsFiltres[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: ThemeQuinca.bordure),
                          ),
                          elevation: 0,
                          child: ListTile(
                            title: Text(prod.nom, style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text("${prod.reference} • Stock : ${prod.quantite}", style: GoogleFonts.inter(fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${prod.prixVente.toInt()} FCFA",
                                  style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: ThemeQuinca.bleuPrincipal),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart, color: ThemeQuinca.bleuPrincipal),
                                  onPressed: prod.quantite > 0 
                                      ? () {
                                          final succes = widget.venteController.ajouterAuPanier(prod);
                                          if (!succes) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Stock insuffisant pour cet article !"), backgroundColor: Colors.red),
                                            );
                                          }
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (!largeEcran) ...[
              const Divider(height: 1, color: ThemeQuinca.bordure),
              Expanded(
                flex: 2,
                child: _buildZonePanier(panier),
              ),
            ],
          ],
        );

        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          appBar: AppBar(
            backgroundColor: ThemeQuinca.bleuPrincipal,
            elevation: 0,
            iconTheme: const IconThemeData(color: ThemeQuinca.texteInverse),
            title: Text(
              "Caisse / Ventes",
              style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeQuinca.texteInverse),
            ),
          ),
          body: largeEcran 
              ? Row(
                  children: [
                    Expanded(flex: 3, child: contenuCaisse),
                    const VerticalDivider(width: 1, color: ThemeQuinca.bordure),
                    Expanded(flex: 2, child: _buildZonePanier(panier)),
                  ],
                )
              : contenuCaisse,
        );
      },
    );
  }

  Widget _buildZonePanier(List panier) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Panier Actuel", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
              Badge(
                label: Text("${panier.length}"),
                backgroundColor: ThemeQuinca.bleuPrincipal,
                child: const Icon(Icons.shopping_bag_outlined, color: ThemeQuinca.texteFonce),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: panier.isEmpty
                ? Center(child: Text("Le panier est vide", style: GoogleFonts.inter(color: ThemeQuinca.texteSecondaire, fontSize: 13)))
                : ListView.builder(
                    itemCount: panier.length,
                    itemBuilder: (context, index) {
                      final item = panier[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.produit.nom, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text("${item.produit.prixVente.toInt()} FCFA x ${item.quantiteChoisie}", style: GoogleFonts.inter(fontSize: 11, color: ThemeQuinca.texteSecondaire)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
                                  onPressed: () => widget.venteController.diminuerOuRetirer(item.produit),
                                ),
                                Text("${item.quantiteChoisie}", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20, color: ThemeQuinca.succes),
                                  onPressed: () => widget.venteController.ajouterAuPanier(item.produit),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(color: ThemeQuinca.bordure),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total à payer :", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                Text(
                  "${widget.venteController.montantTotalGlobal.toInt()} FCFA",
                  style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 18, color: ThemeQuinca.texteFonce),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeQuinca.succes,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: panier.isEmpty ? null : () {
                final reussite = widget.venteController.validerLaVente();
                if (reussite) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vente encaissée avec succès !"), backgroundColor: ThemeQuinca.succes),
                  );
                }
              },
              child: Text(
                "Encaisser la vente",
                style: GoogleFonts.inter(color: ThemeQuinca.texteInverse, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}