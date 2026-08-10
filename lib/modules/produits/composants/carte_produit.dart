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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statut.couleur.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PastilleStatut(couleur: statut.couleur),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produit.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ThemeQuinca.texteFonce,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${produit.reference.isEmpty ? 'Ref auto' : produit.reference} - ${produit.categorie}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _BadgeStatut(statut: statut),
              ],
            ),
            const SizedBox(height: 10),
            _BandeauProduit(
              stock: "${produit.quantite} ${produit.uniteVente}",
              prix: "${produit.prixVente.toInt()} FCFA",
              couleur: statut.couleur,
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
              _DetailProduit(titre: "Unite de vente", valeur: produit.uniteVente),
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
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.inventory_2_outlined, color: couleur),
    );
  }
}

class _BadgeStatut extends StatelessWidget {
  final _StatutProduit statut;

  const _BadgeStatut({required this.statut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statut.couleur.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        statut.libelle,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: statut.couleur,
        ),
      ),
    );
  }
}

class _BandeauProduit extends StatelessWidget {
  final String stock;
  final String prix;
  final Color couleur;

  const _BandeauProduit({
    required this.stock,
    required this.prix,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: ThemeQuinca.fondGris,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniInfoProduit(
              titre: "Stock",
              valeur: stock,
              couleur: couleur,
            ),
          ),
          Container(width: 1, height: 28, color: ThemeQuinca.bordure),
          Expanded(
            child: _MiniInfoProduit(
              titre: "Prix",
              valeur: prix,
              couleur: ThemeQuinca.bleuPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoProduit extends StatelessWidget {
  final String titre;
  final String valeur;
  final Color couleur;

  const _MiniInfoProduit({
    required this.titre,
    required this.valeur,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titre,
          style: ThemeQuinca.corpsTexte.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          valeur,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ThemeQuinca.titrePrincipal.copyWith(
            color: couleur,
            fontSize: 13,
          ),
        ),
      ],
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
