// lib/modules/produits/composants/carte_produit.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../coeur/theme/theme_quinca.dart';
import '../data/produit.dart';

class CarteProduit extends StatelessWidget {
  final Produit produit;
  final bool afficherDetailsCatalogue;

  const CarteProduit({
    super.key,
    required this.produit,
    this.afficherDetailsCatalogue = false,
  });

  @override
  Widget build(BuildContext context) {
    final statut = _StatutProduit.depuisProduit(produit);

    return InkWell(
      onTap: () => _ouvrirDetails(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeQuinca.bordure),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _PastilleStatut(couleur: statut.couleur),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produit.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ThemeQuinca.texteFonce,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${produit.reference.isEmpty ? 'Ref auto' : produit.reference}  |  ${produit.categorie}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ThemeQuinca.corpsTexte.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _InfoCompacte(
                        texte: "${produit.quantite} ${produit.uniteVente}",
                        icone: Icons.inventory_2_outlined,
                        couleur: statut.couleur,
                      ),
                      _InfoCompacte(
                        texte: "${produit.prixVente.toInt()} FCFA",
                        icone: Icons.sell_outlined,
                        couleur: ThemeQuinca.bleuPrincipal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _BadgeStatut(statut: statut),
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: ThemeQuinca.texteSecondaire,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _ouvrirDetails(BuildContext context) {
    final statut = _StatutProduit.depuisProduit(produit);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PastilleStatut(couleur: statut.couleur),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      produit.nom,
                      style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 20),
                    ),
                  ),
                  _BadgeStatut(statut: statut),
                ],
              ),
              const SizedBox(height: 16),
              _DetailProduit(titre: "Reference", valeur: produit.reference),
              _DetailProduit(titre: "Categorie", valeur: produit.categorie),
              _DetailProduit(
                titre: "Unite de vente",
                valeur: produit.uniteVente,
              ),
              _DetailProduit(
                titre: "Stock disponible",
                valeur: "${produit.quantite} ${produit.uniteVente}",
              ),
              _DetailProduit(
                titre: "Seuil d'alerte",
                valeur: "${produit.seuilAlerte} ${produit.uniteVente}",
              ),
              _DetailProduit(
                titre: "Prix d'achat",
                valeur: "${produit.prixAchat.toInt()} FCFA",
              ),
              _DetailProduit(
                titre: "Prix de vente",
                valeur: "${produit.prixVente.toInt()} FCFA",
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatutProduit {
  final String libelle;
  final Color couleur;

  const _StatutProduit({
    required this.libelle,
    required this.couleur,
  });

  factory _StatutProduit.depuisProduit(Produit produit) {
    if (produit.estEnRupture) {
      return const _StatutProduit(
        libelle: "Rupture",
        couleur: ThemeQuinca.rupture,
      );
    }

    if (produit.estEnAlerte) {
      return const _StatutProduit(
        libelle: "Alerte",
        couleur: ThemeQuinca.alerte,
      );
    }

    return const _StatutProduit(
      libelle: "Normal",
      couleur: ThemeQuinca.succes,
    );
  }
}

class _PastilleStatut extends StatelessWidget {
  final Color couleur;

  const _PastilleStatut({required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(Icons.inventory_2_outlined, color: couleur, size: 20),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  final _StatutProduit statut;

  const _BadgeStatut({required this.statut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: statut.couleur.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statut.libelle,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: statut.couleur,
        ),
      ),
    );
  }
}

class _InfoCompacte extends StatelessWidget {
  final String texte;
  final IconData icone;
  final Color couleur;

  const _InfoCompacte({
    required this.texte,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 13, color: couleur),
          const SizedBox(width: 4),
          Text(
            texte,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailProduit extends StatelessWidget {
  final String titre;
  final String valeur;

  const _DetailProduit({
    required this.titre,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(titre, style: ThemeQuinca.corpsTexte),
          ),
          Text(
            valeur.isEmpty ? "Non renseigne" : valeur,
            style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
