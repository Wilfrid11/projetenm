// lib/modules/produits/presentation/historique_entrees.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../coeur/theme/theme_quinca.dart';
import '../../logique/stock_controller.dart';

class HistoriqueEntreesPage extends StatelessWidget {
  final StockController controller;

  const HistoriqueEntreesPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        iconTheme: const IconThemeData(color: ThemeQuinca.texteInverse),
        title: Text(
          "Historique des Entrées",
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeQuinca.texteInverse),
        ),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final entrees = controller.historiqueEntrees;

          // Si le gérant n'a encore rien validé, on affiche ce message propre
          if (entrees.isEmpty) {
            return Center(
              child: Text(
                "Aucun arrivage enregistré pour le moment.",
                style: GoogleFonts.inter(color: ThemeQuinca.texteSecondaire, fontSize: 13),
              ),
            );
          }

          // Si le contrôleur contient des entrées, on les liste ici
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entrees.length,
            itemBuilder: (context, index) {
              final entree = entrees[index];

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: ThemeQuinca.bordure),
                ),
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  leading: const CircleAvatar(
                    backgroundColor: ThemeQuinca.alerte,
                    child: Icon(Icons.downloading_rounded, color: Colors.white),
                  ),
                  title: Text(
                    entree.fournisseur,
                    style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 14, color: ThemeQuinca.texteFonce),
                  ),
                  subtitle: Text(
                    "Le ${entree.dateArrivage} • Par : ${entree.auteur}",
                    style: GoogleFonts.inter(fontSize: 11, color: ThemeQuinca.texteSecondaire),
                  ),
                  // Le bouton poubelle appelle la fonction de nettoyage du contrôleur
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    onPressed: () => controller.masquerEntreeDeLEcran(index),
                  ),
                  children: [
                    const Divider(height: 1, color: ThemeQuinca.bordure),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Produit / Catégorie", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeQuinca.texteSecondaire)),
                                Text("Quantité Reçue", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeQuinca.texteSecondaire)),
                              ],
                            ),
                          ),
                          // On boucle sur la liste des produits rattachés à cet arrivage précis
                          ...entree.lignes.map((ligne) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ligne.nomProduit, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: ThemeQuinca.fondGris, borderRadius: BorderRadius.circular(4)),
                                        child: Text(ligne.categorie, style: GoogleFonts.inter(fontSize: 10, color: ThemeQuinca.texteSecondaire)),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${ligne.quantiteRecue}",
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeQuinca.bleuPrincipal),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}