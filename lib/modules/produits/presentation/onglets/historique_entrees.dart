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
    return ListenableBuilder(
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
                    style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 14),
                  ),
                  subtitle: Text(
                    "Le ${entree.dateArrivage} • Par : ${entree.auteur}",
                    style: ThemeQuinca.corpsTexte.copyWith(fontSize: 11),
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
                                Text("Produit / Catégorie", style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                                Text("Quantité Reçue", style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
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
                                      Text(ligne.nomProduit, style: ThemeQuinca.corpsTexte.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: ThemeQuinca.texteFonce)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: ThemeQuinca.fondGris, borderRadius: BorderRadius.circular(4)),
                                        child: Text(ligne.categorie, style: ThemeQuinca.corpsTexte.copyWith(fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${ligne.quantiteRecue}",
                                  style: ThemeQuinca.corpsTexte.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeQuinca.bleuPrincipal),
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
            },);
        }
    );
  }
}