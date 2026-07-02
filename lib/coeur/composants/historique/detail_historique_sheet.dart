import 'package:flutter/material.dart';

import '../../theme/theme_quinca.dart';

class LigneDetailHistorique {
  final String titre;
  final String sousTitre;
  final String valeur;

  const LigneDetailHistorique({
    required this.titre,
    required this.sousTitre,
    required this.valeur,
  });
}

void afficherDetailHistoriqueSheet(
  BuildContext context, {
  required String titre,
  required String sousTitre,
  required String dateLabel,
  required List<LigneDetailHistorique> lignes,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titre, style: ThemeQuinca.titrePrincipal),
                      const SizedBox(height: 4),
                      Text(dateLabel, style: ThemeQuinca.corpsTexte),
                      Text(sousTitre, style: ThemeQuinca.corpsTexte),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 24, color: ThemeQuinca.bordure),
            Expanded(
              child: ListView.separated(
                itemCount: lignes.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: ThemeQuinca.bordure),
                itemBuilder: (context, index) {
                  final ligne = lignes[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ligne.titre,
                              style: ThemeQuinca.corpsTexte.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ThemeQuinca.texteFonce,
                              ),
                            ),
                            Text(ligne.sousTitre, style: ThemeQuinca.corpsTexte),
                          ],
                        ),
                      ),
                      Text(
                        ligne.valeur,
                        style: ThemeQuinca.titrePrincipal.copyWith(
                          fontSize: 14,
                          color: ThemeQuinca.bleuPrincipal,
                        ),
                      ),
                    ],
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
