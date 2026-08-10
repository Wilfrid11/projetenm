// lib/modules/produits/presentation/onglets/historique_entrees.dart

import 'package:flutter/material.dart';

import '../../../../coeur/composants/historique/carte_historique.dart';
import '../../../../coeur/composants/historique/confirmation_masquer_dialog.dart';
import '../../../../coeur/composants/historique/detail_historique_sheet.dart';
import '../../../../coeur/composants/historique/filtre_periode.dart';
import '../../../../coeur/theme/theme_quinca.dart';
import '../../../historique/data/historique_models.dart';
import '../../logique/stock_controller.dart';

class HistoriqueEntreesPage extends StatefulWidget {
  final StockController controller;

  const HistoriqueEntreesPage({super.key, required this.controller});

  @override
  State<HistoriqueEntreesPage> createState() => _HistoriqueEntreesPageState();
}

class _HistoriqueEntreesPageState extends State<HistoriqueEntreesPage> {
  PeriodeHistorique _periode = PeriodeHistorique.septJours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        title: const Text("Historique des entrees"),
        backgroundColor: ThemeQuinca.bleuPrincipal,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final entrees = widget.controller.historiqueEntrees.where((entree) {
            final date = entree.createdAt;
            if (date == null) return _periode == PeriodeHistorique.tout;
            return dateDansPeriode(date, _periode);
          }).toList();

          return Column(
            children: [
              FiltrePeriode(
                valeur: _periode,
                onChanged: (periode) => setState(() => _periode = periode),
              ),
              Expanded(
                child: _buildListe(entrees),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListe(List<EntreeFournisseur> entrees) {
    if (widget.controller.chargementArrivages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (entrees.isEmpty) {
      return Center(
        child: Text(
          "Aucun arrivage sur cette periode.",
          style: ThemeQuinca.corpsTexte,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entrees.length,
      itemBuilder: (context, index) {
        final entree = entrees[index];
        return CarteHistorique(
          titre: entree.fournisseur,
          sousTitre: "Par : ${entree.auteur}",
          dateLabel: entree.dateArrivage,
          resume:
              "${entree.lignes.length} produits • ${entree.totalQuantites} unites recues",
          icone: Icons.downloading_rounded,
          onTap: () => _ouvrirDetails(entree),
          onMasquer: () => _masquer(entree),
        );
      },
    );
  }

  void _ouvrirDetails(EntreeFournisseur entree) {
    afficherDetailHistoriqueSheet(
      context,
      titre: entree.fournisseur,
      sousTitre: "Par : ${entree.auteur}",
      dateLabel: entree.dateArrivage,
      lignes: entree.lignes
          .map(
            (ligne) => LigneDetailHistorique(
              titre: ligne.nomProduit,
              sousTitre: ligne.categorie,
              valeur: "+${ligne.quantiteRecue} ${ligne.uniteVente}",
            ),
          )
          .toList(),
    );
  }

  Future<void> _masquer(EntreeFournisseur entree) async {
    final confirmer = await confirmerMasquageHistorique(context);
    if (!confirmer || !mounted) return;

    final index = widget.controller.historiqueEntrees.indexWhere(
      (item) => item.id == entree.id,
    );
    if (index == -1) return;

    final succes = await widget.controller.masquerEntreeDeLEcran(index);
    if (!mounted || succes) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.controller.erreurArrivages ??
              "Impossible de masquer cet arrivage.",
        ),
        backgroundColor: ThemeQuinca.rupture,
      ),
    );
  }
}
