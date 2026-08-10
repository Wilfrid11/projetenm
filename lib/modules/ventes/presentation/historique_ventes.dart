// lib/modules/ventes/presentation/historique_ventes.dart

import 'package:flutter/material.dart';

import '../../../coeur/composants/historique/confirmation_masquer_dialog.dart';
import '../../../coeur/composants/historique/detail_historique_sheet.dart';
import '../../../coeur/composants/historique/filtre_periode.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../historique/data/historique_models.dart';
import '../logique/vente_controller.dart';

class HistoriqueVentesPage extends StatefulWidget {
  final VenteController controller;

  const HistoriqueVentesPage({super.key, required this.controller});

  @override
  State<HistoriqueVentesPage> createState() => _HistoriqueVentesPageState();
}

class _HistoriqueVentesPageState extends State<HistoriqueVentesPage> {
  PeriodeHistorique _periode = PeriodeHistorique.septJours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        foregroundColor: Colors.white,
        title: const Text("Registre des ventes"),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final ventes = widget.controller.historiqueVentes.where((vente) {
            final date = vente.createdAt;
            if (date == null) return _periode == PeriodeHistorique.tout;
            return dateDansPeriode(date, _periode);
          }).toList();

          return Column(
            children: [
              FiltrePeriode(
                valeur: _periode,
                onChanged: (periode) => setState(() => _periode = periode),
              ),
              _ResumeHistoriqueVentes(ventes: ventes),
              Expanded(child: _buildListe(ventes)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListe(List<VenteRealisee> ventes) {
    if (ventes.isEmpty) {
      return Center(
        child: Text(
          "Aucune vente sur cette periode.",
          style: ThemeQuinca.corpsTexte,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: ventes.length,
      itemBuilder: (context, index) {
        final vente = ventes[index];
        return _CarteVenteHistorique(
          vente: vente,
          onTap: () => _ouvrirDetails(vente),
          onMasquer: () => _masquer(vente),
        );
      },
    );
  }

  void _ouvrirDetails(VenteRealisee vente) {
    final lignes = vente.panier
        .map(
          (ligne) => LigneDetailHistorique(
            titre: ligne.nomProduit,
            sousTitre:
                "${ligne.prixUnitaire.toInt()} FCFA x ${ligne.quantiteVendue} ${ligne.uniteVente}",
            valeur: "${ligne.montantLigne.toInt()} FCFA",
          ),
        )
        .toList();

    if (vente.montantRecu != null) {
      lignes.add(
        LigneDetailHistorique(
          titre: "Montant recu",
          sousTitre: vente.moyenPaiement,
          valeur: "${vente.montantRecu!.toInt()} FCFA",
        ),
      );
      lignes.add(
        LigneDetailHistorique(
          titre: "Monnaie rendue",
          sousTitre: "Especes",
          valeur: "${(vente.monnaieRendue ?? 0).toInt()} FCFA",
        ),
      );
    }

    afficherDetailHistoriqueSheet(
      context,
      titre: vente.numRecu,
      sousTitre: vente.vendeurNom.isEmpty
          ? "Paiement : ${vente.moyenPaiement}"
          : "Vendeur : ${vente.vendeurNom} - ${vente.moyenPaiement}",
      dateLabel: vente.dateVente,
      lignes: lignes,
    );
  }

  Future<void> _masquer(VenteRealisee vente) async {
    final confirmer = await confirmerMasquageHistorique(context);
    if (!confirmer || !mounted) return;

    final index = widget.controller.historiqueVentes.indexWhere(
      (item) => item.id == vente.id,
    );
    if (index == -1) return;

    final succes = await widget.controller.masquerVenteDeLEcran(index);
    if (!mounted || succes) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.controller.erreurVente ?? "Impossible de masquer la vente.",
        ),
        backgroundColor: ThemeQuinca.rupture,
      ),
    );
  }
}

class _ResumeHistoriqueVentes extends StatelessWidget {
  final List<VenteRealisee> ventes;

  const _ResumeHistoriqueVentes({required this.ventes});

  @override
  Widget build(BuildContext context) {
    final totalVentes = ventes.length;
    final totalArticles =
        ventes.fold<int>(0, (somme, vente) => somme + vente.totalArticles);
    final montantTotal =
        ventes.fold<double>(0, (somme, vente) => somme + vente.montantTotal);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ItemResumeVente(
              titre: "Ventes",
              valeur: "$totalVentes",
              couleur: ThemeQuinca.bleuPrincipal,
            ),
          ),
          Expanded(
            child: _ItemResumeVente(
              titre: "Articles",
              valeur: "$totalArticles",
              couleur: ThemeQuinca.alerte,
            ),
          ),
          Expanded(
            child: _ItemResumeVente(
              titre: "Total",
              valeur: "${montantTotal.toInt()}",
              couleur: ThemeQuinca.succes,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemResumeVente extends StatelessWidget {
  final String titre;
  final String valeur;
  final Color couleur;

  const _ItemResumeVente({
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ThemeQuinca.titrePrincipal.copyWith(
            color: couleur,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(titre, style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _CarteVenteHistorique extends StatelessWidget {
  final VenteRealisee vente;
  final VoidCallback onTap;
  final VoidCallback onMasquer;

  const _CarteVenteHistorique({
    required this.vente,
    required this.onTap,
    required this.onMasquer,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeQuinca.bordure),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: ThemeQuinca.bleuPrincipal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: ThemeQuinca.bleuPrincipal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vente.numRecu,
                        style:
                            ThemeQuinca.titrePrincipal.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        vente.dateVente,
                        style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onMasquer,
                  icon: const Icon(
                    Icons.visibility_off_outlined,
                    color: ThemeQuinca.rupture,
                  ),
                  tooltip: "Masquer",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoVente(
                    titre: "Total",
                    valeur: "${vente.montantTotal.toInt()} FCFA",
                    couleur: ThemeQuinca.succes,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoVente(
                    titre: "Paiement",
                    valeur: vente.moyenPaiement,
                    couleur: ThemeQuinca.bleuPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    vente.vendeurNom.isEmpty
                        ? "Vendeur : non renseigne"
                        : "Vendeur : ${vente.vendeurNom}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12),
                  ),
                ),
                Text(
                  "${vente.totalArticles} article(s)",
                  style: ThemeQuinca.corpsTexte.copyWith(
                    color: ThemeQuinca.texteFonce,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoVente extends StatelessWidget {
  final String titre;
  final String valeur;
  final Color couleur;

  const _InfoVente({
    required this.titre,
    required this.valeur,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: ThemeQuinca.corpsTexte.copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            valeur,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ThemeQuinca.titrePrincipal.copyWith(
              color: couleur,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
