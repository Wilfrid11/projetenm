// lib/modules/ventes/presentation/vente.dart

import 'package:flutter/material.dart';

import '../../../coeur/composants/btn_principal.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../auth/data/user.dart';
import '../../produits/data/produit.dart';
import '../data/panier_item.dart';
import '../logique/vente_controller.dart';

class VentePage extends StatefulWidget {
  final VenteController venteController;
  final User user;

  const VentePage({
    super.key,
    required this.venteController,
    required this.user,
  });

  @override
  State<VentePage> createState() => _VentePageState();
}

class _VentePageState extends State<VentePage> {
  final _rechercheController = TextEditingController();
  String _recherche = "";

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.venteController,
      builder: (context, _) {
        final produits = widget.venteController.stockController.produits
            .where(_filtrerProduit)
            .toList();
        final nombreArticles = widget.venteController.panier.length;

        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          appBar: AppBar(
            backgroundColor: ThemeQuinca.bleuPrincipal,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Ventes",
              style: ThemeQuinca.titrePrincipal.copyWith(
                color: Colors.white,
                fontSize: 19,
              ),
            ),
          ),
          floatingActionButton: _BoutonPanierFlottant(
            nombreArticles: nombreArticles,
            total: widget.venteController.montantTotalGlobal,
            onTap: () => _ouvrirPanier(context),
          ),
          body: Column(
            children: [
              _BarreRechercheVente(
                controller: _rechercheController,
                onChanged: (valeur) => setState(() => _recherche = valeur),
                onClear: () {
                  _rechercheController.clear();
                  setState(() => _recherche = "");
                },
              ),
              _ResumeVente(
                produitsDisponibles: produits.length,
                articlesPanier: nombreArticles,
                total: widget.venteController.montantTotalGlobal,
              ),
              Expanded(
                child: produits.isEmpty
                    ? const _EtatVideVente()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                        itemCount: produits.length,
                        itemBuilder: (context, index) {
                          final produit = produits[index];
                          return _CarteProduitVente(
                            produit: produit,
                            quantiteDansPanier: widget.venteController
                                .quantiteDansPanier(produit),
                            onAjouter: () => _ouvrirChoixQuantite(
                              context,
                              produit,
                            ),
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

  bool _filtrerProduit(Produit produit) {
    final recherche = _recherche.toLowerCase().trim();
    if (recherche.isEmpty) return true;

    return produit.nom.toLowerCase().contains(recherche) ||
        produit.reference.toLowerCase().contains(recherche) ||
        produit.categorie.toLowerCase().contains(recherche);
  }

  void _ouvrirChoixQuantite(BuildContext context, Produit produit) {
    if (produit.quantite <= 0) {
      _message(context, "Ce produit est en rupture.", ThemeQuinca.rupture);
      return;
    }

    final quantiteDejaChoisie =
        widget.venteController.quantiteDansPanier(produit);
    final quantiteRestante = produit.quantite - quantiteDejaChoisie;

    if (quantiteRestante <= 0) {
      _message(context, "Tout le stock disponible est deja dans le panier.",
          ThemeQuinca.alerte);
      return;
    }

    final quantiteCtrl = TextEditingController(text: "1");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        int quantite = 1;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final sousTotal = quantite * produit.prixVente;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 4,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produit.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Stock disponible : $quantiteRestante ${produit.uniteVente}",
                      style: ThemeQuinca.corpsTexte,
                    ),
                    const SizedBox(height: 10),
                    _InfoPrixVente(produit: produit),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _BoutonQuantite(
                          icone: Icons.remove,
                          onTap: quantite > 1
                              ? () {
                                  setModalState(() {
                                    quantite--;
                                    quantiteCtrl.text = "$quantite";
                                  });
                                }
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: quantiteCtrl,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: ThemeQuinca.inputDecoration(
                              label: "Quantite",
                              icone: Icons.numbers_outlined,
                            ),
                            onChanged: (valeur) {
                              final saisie = int.tryParse(valeur.trim());
                              if (saisie == null) return;
                              final limitee = saisie.clamp(
                                1,
                                quantiteRestante,
                              );
                              setModalState(() => quantite = limitee);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        _BoutonQuantite(
                          icone: Icons.add,
                          onTap: quantite < quantiteRestante
                              ? () {
                                  setModalState(() {
                                    quantite++;
                                    quantiteCtrl.text = "$quantite";
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeQuinca.fondGris,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ThemeQuinca.bordure),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sous-total", style: ThemeQuinca.corpsTexte),
                          Text(
                            "${sousTotal.toInt()} FCFA",
                            style: ThemeQuinca.titrePrincipal.copyWith(
                              color: ThemeQuinca.bleuPrincipal,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    BtnPrincipal(
                      texte: "Ajouter au panier",
                      onPressed: () {
                        final saisie =
                            int.tryParse(quantiteCtrl.text.trim()) ?? quantite;
                        final quantiteValidee = saisie.clamp(
                          1,
                          quantiteRestante,
                        );
                        final succes =
                            widget.venteController.ajouterQuantiteAuPanier(
                          produit,
                          quantiteValidee,
                        );
                        Navigator.pop(sheetContext);

                        _message(
                          context,
                          succes
                              ? "Produit ajoute au panier."
                              : "Stock insuffisant.",
                          succes ? ThemeQuinca.succes : ThemeQuinca.rupture,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => quantiteCtrl.dispose());
  }

  void _ouvrirPanier(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: widget.venteController,
          builder: (context, _) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.78,
              minChildSize: 0.45,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                final panier = widget.venteController.panier;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Panier",
                              style: ThemeQuinca.titrePrincipal.copyWith(
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Text(
                            "${panier.length} article(s)",
                            style: ThemeQuinca.corpsTexte,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: panier.isEmpty
                            ? const _PanierVide()
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: panier.length,
                                itemBuilder: (context, index) {
                                  return _LignePanier(
                                    item: panier[index],
                                    onMoins: () => widget.venteController
                                        .diminuerOuRetirer(
                                      panier[index].produit,
                                    ),
                                    onPlus: () {
                                      final succes = widget.venteController
                                          .ajouterAuPanier(
                                        panier[index].produit,
                                      );
                                      if (!succes) {
                                        _message(
                                          context,
                                          "Stock insuffisant.",
                                          ThemeQuinca.rupture,
                                        );
                                      }
                                    },
                                    onRetirer: () => widget.venteController
                                        .definirQuantite(
                                      panier[index].produit,
                                      0,
                                    ),
                                  );
                                },
                              ),
                      ),
                      _ZoneValidationPanier(
                        total: widget.venteController.montantTotalGlobal,
                        validationEnCours:
                            widget.venteController.validationEnCours,
                        onValider: panier.isEmpty
                            ? null
                            : () => _ouvrirPaiement(sheetContext),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _ouvrirPaiement(BuildContext panierContext) {
    Navigator.pop(panierContext);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Paiement", style: ThemeQuinca.titrePrincipal),
              const SizedBox(height: 8),
              Text(
                "Choisissez le mode utilise par le client.",
                style: ThemeQuinca.corpsTexte,
              ),
              const SizedBox(height: 18),
              _ModePaiement(
                titre: "Especes",
                icone: Icons.payments_outlined,
                onTap: () => _confirmerPaiement(context, "Especes"),
              ),
              _ModePaiement(
                titre: "MTN",
                icone: Icons.phone_android_rounded,
                onTap: () => _confirmerPaiement(context, "MTN"),
              ),
              _ModePaiement(
                titre: "Moov",
                icone: Icons.phone_android_rounded,
                onTap: () => _confirmerPaiement(context, "Moov"),
              ),
              _ModePaiement(
                titre: "Celtiis",
                icone: Icons.phone_android_rounded,
                onTap: () => _confirmerPaiement(context, "Celtiis"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmerPaiement(BuildContext paiementContext, String mode) {
    Navigator.pop(paiementContext);

    final montantRecuCtrl = TextEditingController();
    final total = widget.venteController.montantTotalGlobal;
    final estEspeces = mode == "Especes";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        double monnaie = 0;

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (estEspeces) {
              final recu = double.tryParse(montantRecuCtrl.text.trim()) ?? 0;
              monnaie = recu - total;
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirmer la vente",
                    style: ThemeQuinca.titrePrincipal,
                  ),
                  const SizedBox(height: 8),
                  _ResumePaiement(mode: mode, total: total),
                  if (estEspeces) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: montantRecuCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setModalState(() {}),
                      decoration: ThemeQuinca.inputDecoration(
                        label: "Montant recu",
                        icone: Icons.payments_outlined,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Monnaie a rendre : ${monnaie < 0 ? 0 : monnaie.toInt()} FCFA",
                      style: ThemeQuinca.corpsTexte.copyWith(
                        fontWeight: FontWeight.w800,
                        color: monnaie < 0
                            ? ThemeQuinca.rupture
                            : ThemeQuinca.succes,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeQuinca.bleuPrincipal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Validez seulement apres confirmation du paiement $mode.",
                        style: ThemeQuinca.corpsTexte.copyWith(
                          color: ThemeQuinca.texteFonce,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  BtnPrincipal(
                    texte: widget.venteController.validationEnCours
                        ? "Validation..."
                        : "Valider la vente",
                    isLoading: widget.venteController.validationEnCours,
                    onPressed: () async {
                      final montantRecu = estEspeces
                          ? double.tryParse(montantRecuCtrl.text.trim())
                          : null;

                      if (estEspeces &&
                          (montantRecu == null || montantRecu < total)) {
                        _message(
                          context,
                          "Montant recu insuffisant.",
                          ThemeQuinca.rupture,
                        );
                        return;
                      }

                      final succes =
                          await widget.venteController.validerLaVente(
                        moyenPaiement: mode,
                        vendeurId: widget.user.id,
                        vendeurNom: "${widget.user.prenom} ${widget.user.nom}",
                        montantRecu: montantRecu,
                        monnaieRendue:
                            estEspeces ? (montantRecu! - total) : null,
                      );

                      if (!context.mounted) return;
                      Navigator.pop(sheetContext);
                      _message(
                        context,
                        succes
                            ? "Vente enregistree avec succes."
                            : widget.venteController.erreurVente ??
                                "Vente impossible.",
                        succes ? ThemeQuinca.succes : ThemeQuinca.rupture,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _message(BuildContext context, String message, Color couleur) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: couleur,
      ),
    );
  }
}

class _BarreRechercheVente extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _BarreRechercheVente({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeQuinca.bleuPrincipal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Rechercher un produit a vendre",
          hintStyle: ThemeQuinca.corpsTexte,
          prefixIcon: const Icon(Icons.search, color: ThemeQuinca.texteSecondaire),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _ResumeVente extends StatelessWidget {
  final int produitsDisponibles;
  final int articlesPanier;
  final double total;

  const _ResumeVente({
    required this.produitsDisponibles,
    required this.articlesPanier,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResumeVenteItem(
              titre: "Produits",
              valeur: "$produitsDisponibles",
              couleur: ThemeQuinca.bleuPrincipal,
            ),
          ),
          Expanded(
            child: _ResumeVenteItem(
              titre: "Panier",
              valeur: "$articlesPanier",
              couleur: ThemeQuinca.alerte,
            ),
          ),
          Expanded(
            child: _ResumeVenteItem(
              titre: "Total",
              valeur: "${total.toInt()}",
              couleur: ThemeQuinca.succes,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeVenteItem extends StatelessWidget {
  final String titre;
  final String valeur;
  final Color couleur;

  const _ResumeVenteItem({
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
            fontSize: 18,
          ),
        ),
        Text(titre, style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _CarteProduitVente extends StatelessWidget {
  final Produit produit;
  final int quantiteDansPanier;
  final VoidCallback onAjouter;

  const _CarteProduitVente({
    required this.produit,
    required this.quantiteDansPanier,
    required this.onAjouter,
  });

  @override
  Widget build(BuildContext context) {
    final enRupture = produit.quantite <= 0;
    final couleurStock = enRupture
        ? ThemeQuinca.rupture
        : produit.estEnAlerte
            ? ThemeQuinca.alerte
            : ThemeQuinca.succes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleurStock.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: couleurStock.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.sell_outlined, color: couleurStock),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produit.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "${produit.reference.isEmpty ? 'Ref auto' : produit.reference} - Stock ${produit.quantite} ${produit.uniteVente}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12),
                ),
                if (quantiteDansPanier > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    "$quantiteDansPanier deja dans le panier",
                    style: ThemeQuinca.corpsTexte.copyWith(
                      color: ThemeQuinca.alerte,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${produit.prixVente.toInt()} FCFA",
                style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: enRupture ? null : onAjouter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeQuinca.bleuPrincipal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(86, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Ajouter"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoutonPanierFlottant extends StatelessWidget {
  final int nombreArticles;
  final double total;
  final VoidCallback onTap;

  const _BoutonPanierFlottant({
    required this.nombreArticles,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: ThemeQuinca.bleuPrincipal,
      foregroundColor: Colors.white,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_cart_outlined),
          if (nombreArticles > 0)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: ThemeQuinca.alerte,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$nombreArticles",
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      label: Text("${total.toInt()} FCFA"),
  );
  }
}

class _InfoPrixVente extends StatelessWidget {
  final Produit produit;

  const _InfoPrixVente({required this.produit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeQuinca.fondGris,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Prix unitaire", style: ThemeQuinca.corpsTexte),
          Text(
            "${produit.prixVente.toInt()} FCFA / ${produit.uniteVente}",
            style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _BoutonQuantite extends StatelessWidget {
  final IconData icone;
  final VoidCallback? onTap;

  const _BoutonQuantite({
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      icon: Icon(icone),
      style: IconButton.styleFrom(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        disabledBackgroundColor: ThemeQuinca.bordure,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _LignePanier extends StatelessWidget {
  final PanierItem item;
  final VoidCallback onMoins;
  final VoidCallback onPlus;
  final VoidCallback onRetirer;

  const _LignePanier({
    required this.item,
    required this.onMoins,
    required this.onPlus,
    required this.onRetirer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeQuinca.fondGris,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.produit.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.produit.prixVente.toInt()} FCFA x ${item.quantiteChoisie}",
                  style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.montantTotal.toInt()} FCFA",
                  style: ThemeQuinca.titrePrincipal.copyWith(
                    color: ThemeQuinca.bleuPrincipal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMoins,
            icon: const Icon(Icons.remove_circle_outline),
            color: ThemeQuinca.bleuPrincipal,
          ),
          Text(
            "${item.quantiteChoisie}",
            style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline),
            color: ThemeQuinca.bleuPrincipal,
          ),
          IconButton(
            onPressed: onRetirer,
            icon: const Icon(Icons.delete_outline),
            color: ThemeQuinca.rupture,
          ),
        ],
      ),
    );
  }
}

class _ZoneValidationPanier extends StatelessWidget {
  final double total;
  final bool validationEnCours;
  final VoidCallback? onValider;

  const _ZoneValidationPanier({
    required this.total,
    required this.validationEnCours,
    required this.onValider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ThemeQuinca.bordure)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total a payer", style: ThemeQuinca.corpsTexte),
              Text(
                "${total.toInt()} FCFA",
                style: ThemeQuinca.titrePrincipal.copyWith(
                  color: ThemeQuinca.bleuPrincipal,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (onValider == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text("Panier vide"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            BtnPrincipal(
              texte: validationEnCours ? "Validation..." : "Choisir paiement",
              isLoading: validationEnCours,
              onPressed: onValider!,
            ),
        ],
      ),
    );
  }
}

class _ModePaiement extends StatelessWidget {
  final String titre;
  final IconData icone;
  final VoidCallback onTap;

  const _ModePaiement({
    required this.titre,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icone, color: ThemeQuinca.bleuPrincipal),
        title: Text(
          titre,
          style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _ResumePaiement extends StatelessWidget {
  final String mode;
  final double total;

  const _ResumePaiement({
    required this.mode,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeQuinca.fondGris,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mode", style: ThemeQuinca.corpsTexte),
              Text(
                mode,
                style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: ThemeQuinca.corpsTexte),
              Text(
                "${total.toInt()} FCFA",
                style: ThemeQuinca.titrePrincipal.copyWith(
                  color: ThemeQuinca.bleuPrincipal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EtatVideVente extends StatelessWidget {
  const _EtatVideVente();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: ThemeQuinca.texteSecondaire,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              "Aucun produit disponible",
              style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              "Verifiez votre recherche ou ajoutez des produits au catalogue.",
              style: ThemeQuinca.corpsTexte,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PanierVide extends StatelessWidget {
  const _PanierVide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Le panier est vide.",
        style: ThemeQuinca.corpsTexte,
      ),
    );
  }
}
