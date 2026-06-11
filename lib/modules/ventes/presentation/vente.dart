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
  
  // Moyen de paiement sélectionné par défaut
  String _moyenPaiementSelectionne = "Espèces"; 

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.venteController,
      builder: (context, _) {
        final tousLesProduits = widget.venteController.stockController.produits;
        final panier = widget.venteController.panier;

        final produitsFiltres = tousLesProduits.where((prod) {
          final correspondRecherche = prod.nom.toLowerCase().contains(_rechercheQuery.toLowerCase()) ||
              prod.reference.toLowerCase().contains(_rechercheQuery.toLowerCase());
          final correspondCategorie = _categorieSelectionnee == "Tout" || 
              prod.categorie.toLowerCase() == _categorieSelectionnee.toLowerCase();
          return correspondRecherche && correspondCategorie;
        }).toList();

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
          body: Column(
            children: [
              // Ligne supérieure : Filtre + Icône Panier Mobile
              Row(
                children: [
                  Expanded(
                    child: Filtre(
                      categorieInitiale: _categorieSelectionnee,
                      onRechercheChange: (valeur) => setState(() => _rechercheQuery = valeur),
                      onCategorieChange: (cat) => setState(() => _categorieSelectionnee = cat),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart, size: 28, color: ThemeQuinca.bleuPrincipal),
                          onPressed: () => _ouvrirModalPanier(context, panier),
                        ),
                        if (panier.isNotEmpty)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                "${panier.length}",
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Zone d'affichage des articles
              Expanded(
                child: produitsFiltres.isEmpty
                    ? Center(child: Text("Aucun produit disponible", style: GoogleFonts.inter(color: ThemeQuinca.texteSecondaire)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                                const SnackBar(content: Text("Stock insuffisant !"), backgroundColor: Colors.red),
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
            ],
          ),
        );
      },
    );
  }

  // Feuille de détails du panier mobile (showModalBottomSheet)
  void _ouvrirModalPanier(BuildContext context, List panier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder( // ◄ Utilisation de StatefulBuilder pour animer les boutons radio internes
          builder: (context, setModalState) {
            return ListenableBuilder(
              listenable: widget.venteController,
              builder: (context, _) {
                final panierActuel = widget.venteController.panier;
                return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.75, // Légèrement augmenté pour l'espace radio
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Panier Actuel", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.close, color: ThemeQuinca.texteSecondaire),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Expanded(
                          child: panierActuel.isEmpty
                              ? Center(child: Text("Le panier est vide", style: GoogleFonts.inter(color: ThemeQuinca.texteSecondaire, fontSize: 13)))
                              : ListView.builder(
                                  itemCount: panierActuel.length,
                                  itemBuilder: (context, index) {
                                    final item = panierActuel[index];
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
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(Icons.delete_forever_outlined, size: 20, color: Colors.red),
                                                onPressed: () {
                                                  while (item.quantiteChoisie > 0) {
                                                    widget.venteController.diminuerOuRetirer(item.produit);
                                                  }
                                                },
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
                        
                        // SECTION : Sélection du moyen de paiement
                        Text(
                          "Mode de règlement :",
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: ThemeQuinca.texteFonce),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text("Espèces"),
                              selected: _moyenPaiementSelectionne == "Espèces",
                              onSelected: (bool selected) {
                                if (selected) {
                                  setModalState(() => _moyenPaiementSelectionne = "Espèces");
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text("Mobile Money"),
                              selected: _moyenPaiementSelectionne == "Mobile Money",
                              onSelected: (bool selected) {
                                if (selected) {
                                  setModalState(() => _moyenPaiementSelectionne = "Mobile Money");
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
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
                            onPressed: panierActuel.isEmpty ? null : () {
                              // CORRECTION ICI : On passe la variable dynamique en argument ! ✨
                              final reussite = widget.venteController.validerLaVente(_moyenPaiementSelectionne);
                              if (reussite) {
                                Navigator.pop(context); // Ferme la feuille
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Vente encaissée en $_moyenPaiementSelectionne avec succès !"), 
                                    backgroundColor: ThemeQuinca.succes,
                                  ),
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
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}