// lib/modules/produit/presentation/produit.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../../coeur/composants/filtre.dart';
import '../logique/stock_controller.dart';
import '../composants/menu_lateral.dart';
import '../composants/carte_produit.dart';
import '../../auth/data/user.dart'; // Import nécessaire pour passer l'utilisateur au menu latéral
import '../../ventes/logique/vente_controller.dart';
import 'onglets/catalogue.dart';
import 'onglets/arrivage.dart';
import 'onglets/historique_entrees.dart';

class ProduitPage extends StatefulWidget {
  final StockController stockController;
  final VenteController venteController;
  final User user; // 👈 Doit être présent ici

  const ProduitPage({
    super.key,
    required this.stockController,
    required this.venteController,
    required this.user, // 👈 Et requis ici
  });

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _rechercheQuery = "";
  String _categorieSelectionnee = "Tout";
  bool _isActionActive = false; // Flag pour savoir si on affiche un formulaire ou la liste

  @override
  void initState() {
    super.initState();
    // Le gérant n'a pas accès à l'onglet "Catalogue" (création de fiches)
    _tabController = TabController(length: widget.user.isAdmin ? 3 : 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _isActionActive = true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.stockController,
      builder: (context, _) {
        final tousLesProduits = widget.stockController.produits;
        final listeFiltree = tousLesProduits.where((prod) {
          final matchSearch = prod.nom.toLowerCase().contains(_rechercheQuery.toLowerCase()) ||
              prod.reference.toLowerCase().contains(_rechercheQuery.toLowerCase());
          final matchCat = _categorieSelectionnee == "Tout" ||
              prod.categorie.toLowerCase() == _categorieSelectionnee.toLowerCase();
          return matchSearch && matchCat;
        }).toList();

        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: ThemeQuinca.texteFonce),
            title: Text("Gestion de Stock", style: ThemeQuinca.titrePrincipal.copyWith(color: ThemeQuinca.texteFonce, fontSize: 18)),
            actions: [
              if (_isActionActive)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => setState(() => _isActionActive = false),
                  tooltip: "Fermer l'action",
                )
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: ThemeQuinca.alerte,
              indicatorWeight: 3,
              labelColor: ThemeQuinca.bleuPrincipal,
              unselectedLabelColor: ThemeQuinca.texteSecondaire,
              labelStyle: ThemeQuinca.corpsTexte.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: widget.user.isAdmin 
                ? const [
                    Tab(text: "Catalogue", icon: Icon(Icons.playlist_add_rounded, size: 20)),
                    Tab(text: "Arrivage", icon: Icon(Icons.input_rounded, size: 20)),
                    Tab(text: "Historique", icon: Icon(Icons.history_rounded, size: 20)),
                  ]
                : const [
                    Tab(text: "Arrivage", icon: Icon(Icons.input_rounded, size: 20)),
                    Tab(text: "Historique", icon: Icon(Icons.history_rounded, size: 20)),
                  ],
            ),
          ),
          // Drawer retiré comme demandé
          body: _isActionActive 
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    if (widget.user.isAdmin)
                      CataloguePage(controller: widget.stockController, user: widget.user),
                    ArrivagePage(controller: widget.stockController, user: widget.user),
                    HistoriqueEntreesPage(controller: widget.stockController),
                  ],
                )
              : Column(
                  children: [
                    Filtre(
                      categorieInitiale: _categorieSelectionnee,
                      onRechercheChange: (val) => setState(() => _rechercheQuery = val),
                      onCategorieChange: (cat) => setState(() => _categorieSelectionnee = cat),
                    ),
                    Expanded(
                      child: listeFiltree.isEmpty
                          ? const Center(child: Text("Aucun produit ne correspond à votre recherche"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 20),
                              itemCount: listeFiltree.length,
                              itemBuilder: (context, index) {
                                final p = listeFiltree[index];
                                return CarteProduit(produit: p, afficherDetailsCatalogue: false);
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
