// lib/modules/produit/presentation/produit.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../../coeur/composants/filtre.dart';
import '../logique/stock_controller.dart';
import '../composants/menu_lateral.dart';
import '../composants/carte_produit.dart';
import '../../auth/data/user.dart'; // Import nécessaire pour passer l'utilisateur au menu latéral
import 'formulaire_produit.dart'; // Import ajouté

class ProduitPage extends StatefulWidget {
  final StockController stockController;
  final User user; // 👈 Doit être présent ici

  const ProduitPage({
    super.key,
    required this.stockController,
    required this.user, // 👈 Et requis ici
  });

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  String _rechercheQuery = "";
  String _categorieSelectionnee = "Tout";

  @override
  Widget build(BuildContext context) {
    // Le ListenableBuilder écoute le StockController et reconstruit l'écran dès que le stock change
    return ListenableBuilder(
      listenable: widget.stockController,
      builder: (context, _) {
        final tousLesProduits = widget.stockController.produits;

        // Filtrage en cascade (Recherche textuelle + Catégorie)
        final listeFiltree = tousLesProduits.where((prod) {
          final correspondRecherche =
              prod.nom.toLowerCase().contains(_rechercheQuery.toLowerCase()) ||
              prod.reference.toLowerCase().contains(
                _rechercheQuery.toLowerCase(),
              );

          final correspondCategorie =
              _categorieSelectionnee == "Tout" ||
              prod.categorie.toLowerCase() ==
                  _categorieSelectionnee.toLowerCase();

          return correspondRecherche && correspondCategorie;
        }).toList();

        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          appBar: AppBar(
            backgroundColor: ThemeQuinca.bleuPrincipal,
            elevation: 0,
            iconTheme: const IconThemeData(color: ThemeQuinca.texteInverse),
            title: Text(
              "Stock & Produits",
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeQuinca.texteInverse,
              ),
            ),
            centerTitle: true,
          ),
          // On passe notre menu latéral personnalisé
          drawer: MenuLateral(
            stockController: widget.stockController,
            user: widget
                .user, // 👈 Ajout de l'utilisateur connecté requis par le menu
          ),
          body: Column(
            children: [
              // Insertion du filtre partagé moderne qu'on a conçu ensemble
              Filtre(
                categorieInitiale: _categorieSelectionnee,
                onRechercheChange: (valeur) {
                  setState(() {
                    _rechercheQuery = valeur;
                  });
                },
                onCategorieChange: (cat) {
                  setState(() {
                    _categorieSelectionnee = cat;
                  });
                },
              ),

              // Zone d'affichage de la liste des produits
              Expanded(
                child: listeFiltree.isEmpty
                    ? Center(
                        child: Text(
                          "Aucun produit ne correspond à votre recherche",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: ThemeQuinca.texteSecondaire,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        itemCount: listeFiltree.length,
                        itemBuilder: (context, index) {
                          final p = listeFiltree[index];
                          return Stack(
                            children: [
                              CarteProduit(produit: p, afficherDetailsCatalogue: false), // La carte produit elle-même
                              if (widget.user.role == 'admin') // Seul l'admin peut voir ces options
                                Positioned(
                                  right: 10, top: 10,
                                  child: PopupMenuButton(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    itemBuilder: (c) => [
                                      const PopupMenuItem(value: 'edit', child: Text("Modifier")),
                                      const PopupMenuItem(value: 'delete', child: Text("Supprimer", style: TextStyle(color: Colors.red))),
                                    ],
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        Navigator.push(context, MaterialPageRoute(builder: (c) => 
                                          FormulaireProduitPage(controller: widget.stockController, produitExistant: p)));
                                      } else {
                                        widget.stockController.supprimerProduit(p.id);
                                      }
                                    },
                                  ),
                                )
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: widget.user.role == 'admin' ? FloatingActionButton(
            backgroundColor: ThemeQuinca.bleuPrincipal,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => 
              FormulaireProduitPage(controller: widget.stockController))),
          ) : null,
        );
      },
    );
  }
}
