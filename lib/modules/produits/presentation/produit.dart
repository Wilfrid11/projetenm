// lib/modules/produits/presentation/produit.dart

import 'package:flutter/material.dart';

import '../../../coeur/composants/filtre.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../auth/data/user.dart';
import '../../ventes/logique/vente_controller.dart';
import '../composants/carte_produit.dart';
import '../composants/menu_lateral.dart';
import '../logique/stock_controller.dart';

class ProduitPage extends StatefulWidget {
  final StockController stockController;
  final VenteController venteController;
  final User user;

  const ProduitPage({
    super.key,
    required this.stockController,
    required this.venteController,
    required this.user,
  });

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
  String _rechercheQuery = "";
  String _categorieSelectionnee = "Tout";

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.stockController,
      builder: (context, _) {
        final tousLesProduits = widget.stockController.produits;
        final listeFiltree = tousLesProduits.where((prod) {
          final recherche = _rechercheQuery.toLowerCase();
          final matchRecherche = prod.nom.toLowerCase().contains(recherche) ||
              prod.reference.toLowerCase().contains(recherche);
          final matchCategorie = _categorieSelectionnee == "Tout" ||
              prod.categorie.toLowerCase() ==
                  _categorieSelectionnee.toLowerCase();

          return matchRecherche && matchCategorie;
        }).toList();

        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          drawer: MenuLateral(
            stockController: widget.stockController,
            user: widget.user,
          ),
          appBar: AppBar(
            backgroundColor: ThemeQuinca.bleuPrincipal,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Produits",
              style: ThemeQuinca.titrePrincipal.copyWith(
                color: Colors.white,
                fontSize: 19,
              ),
            ),
          ),
          body: Column(
            children: [
              Filtre(
                categorieInitiale: _categorieSelectionnee,
                onRechercheChange: (valeur) {
                  setState(() => _rechercheQuery = valeur);
                },
                onCategorieChange: (categorie) {
                  setState(() => _categorieSelectionnee = categorie);
                },
              ),
              _ResumeInventaire(
                totalProduits: tousLesProduits.length,
                ruptures: widget.stockController.produitsEnRupture.length,
                alertes: widget.stockController.produitsEnAlerte.length,
              ),
              Expanded(
                child: widget.stockController.chargementProduits
                    ? const Center(child: CircularProgressIndicator())
                    : listeFiltree.isEmpty
                        ? const _EtatVideProduits()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                            itemCount: listeFiltree.length,
                            itemBuilder: (context, index) {
                              return CarteProduit(
                                produit: listeFiltree[index],
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

class _ResumeInventaire extends StatelessWidget {
  final int totalProduits;
  final int ruptures;
  final int alertes;

  const _ResumeInventaire({
    required this.totalProduits,
    required this.ruptures,
    required this.alertes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResumeItem(
              titre: "Produits",
              valeur: "$totalProduits",
              couleur: ThemeQuinca.bleuPrincipal,
            ),
          ),
          Expanded(
            child: _ResumeItem(
              titre: "Alertes",
              valeur: "$alertes",
              couleur: ThemeQuinca.alerte,
            ),
          ),
          Expanded(
            child: _ResumeItem(
              titre: "Ruptures",
              valeur: "$ruptures",
              couleur: ThemeQuinca.rupture,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeItem extends StatelessWidget {
  final String titre;
  final String valeur;
  final Color couleur;

  const _ResumeItem({
    required this.titre,
    required this.valeur,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valeur,
          style: ThemeQuinca.titrePrincipal.copyWith(
            color: couleur,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          titre,
          style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _EtatVideProduits extends StatelessWidget {
  const _EtatVideProduits();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: ThemeQuinca.texteSecondaire,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              "Aucun produit trouve",
              style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Ouvrez le menu pour ajouter des produits au catalogue.",
              style: ThemeQuinca.corpsTexte,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
