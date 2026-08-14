// lib/modules/produits/presentation/onglets/arrivage.dart

import 'package:flutter/material.dart';

import '../../../../coeur/composants/btn_principal.dart';
import '../../../../coeur/theme/theme_quinca.dart';
import '../../../auth/data/user.dart';
import '../../../fournisseurs/data/fournisseur.dart';
import '../../../fournisseurs/logique/fournisseur_controller.dart';
import '../../../historique/data/historique_models.dart';
import '../../data/produit.dart';
import '../../logique/stock_controller.dart';

class ArrivagePage extends StatefulWidget {
  final StockController controller;
  final User user;

  const ArrivagePage({
    super.key,
    required this.controller,
    required this.user,
  });

  @override
  State<ArrivagePage> createState() => _ArrivagePageState();
}

class _ArrivagePageState extends State<ArrivagePage> {
  final FournisseurController _fournisseurController = FournisseurController();
  final List<_LigneArrivageForm> _lignes = [];
  Fournisseur? _fournisseurSelectionne;
  bool _validationEnCours = false;

  @override
  void initState() {
    super.initState();
    _fournisseurController.charger(widget.user.boutiqueId);
    _ajouterLigne();
  }

  @override
  void dispose() {
    _fournisseurController.dispose();
    for (final ligne in _lignes) {
      ligne.dispose();
    }
    super.dispose();
  }

  void _ajouterLigne() {
    setState(() => _lignes.add(_LigneArrivageForm()));
  }

  void _supprimerLigne(int index) {
    if (_lignes.length <= 1) return;
    _lignes[index].dispose();
    setState(() => _lignes.removeAt(index));
  }

  Future<void> _validerArrivage() async {
    if (_validationEnCours) return;

    final fournisseur = _fournisseurSelectionne;
    if (fournisseur == null) {
      _afficherErreur("Selectionnez le fournisseur de cet arrivage.");
      return;
    }

    final lignesHistorique = <LigneEntree>[];
    final produitsDisponibles = widget.controller.produits;

    for (var i = 0; i < _lignes.length; i++) {
      final ligne = _lignes[i];
      final produitId = ligne.produitId;
      final quantite = int.tryParse(ligne.quantiteCtrl.text.trim());

      if (produitId == null || produitId.isEmpty) {
        _afficherErreur("Ligne ${i + 1} : choisissez un produit.");
        return;
      }
      if (quantite == null || quantite <= 0) {
        _afficherErreur("Ligne ${i + 1} : quantite recue invalide.");
        return;
      }

      final produit = produitsDisponibles.firstWhere(
        (item) => item.id == produitId,
      );

      lignesHistorique.add(
        LigneEntree(
          produitId: produit.id,
          nomProduit: produit.nom,
          categorie: produit.categorie,
          uniteVente: produit.uniteVente,
          quantiteRecue: quantite,
        ),
      );
    }

    final maintenant = DateTime.now();
    final entree = EntreeFournisseur(
      id: '',
      boutiqueId: widget.user.boutiqueId,
      fournisseurId: fournisseur.id,
      fournisseur: fournisseur.nom,
      dateArrivage: _dateLisible(maintenant),
      auteurId: widget.user.id,
      auteur: "${widget.user.prenom} ${widget.user.nom}",
      lignes: lignesHistorique,
      createdAt: maintenant,
      visible: true,
    );

    setState(() => _validationEnCours = true);
    final succes = await widget.controller.validerArrivage(entree);
    if (!mounted) return;
    setState(() => _validationEnCours = false);

    if (!succes) {
      _afficherErreur(
        widget.controller.erreurArrivages ??
            "Impossible de valider l'arrivage.",
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Arrivage valide et stock mis a jour.")),
    );

    for (final ligne in _lignes) {
      ligne.dispose();
    }
    setState(() {
      _lignes
        ..clear()
        ..add(_LigneArrivageForm());
      _fournisseurSelectionne = null;
    });
  }

  String _dateLisible(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    final heure = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$jour/$mois/${date.year} a $heure:$minute";
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ThemeQuinca.rupture),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        title: const Text("Arrivage"),
        backgroundColor: ThemeQuinca.bleuPrincipal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Ajouter une ligne",
            onPressed: _validationEnCours ? null : _ajouterLigne,
            icon: const Icon(Icons.add_rounded, size: 30),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable:
            Listenable.merge([widget.controller, _fournisseurController]),
        builder: (context, _) {
          final produits = widget.controller.produits;
          final fournisseurs = _fournisseurController.fournisseurs;

          if (widget.controller.chargementProduits ||
              _fournisseurController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (produits.isEmpty) {
            return const Center(
              child: Text("Ajoutez d'abord des produits au catalogue."),
            );
          }

          if (fournisseurs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  "Aucun fournisseur disponible. L'admin doit ajouter un fournisseur avant de valider un arrivage.",
                  textAlign: TextAlign.center,
                  style: ThemeQuinca.corpsTexte,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Fournisseur>(
                  initialValue: _fournisseurSelectionne,
                  decoration: ThemeQuinca.inputDecoration(
                    label: "Fournisseur",
                    icone: Icons.local_shipping_outlined,
                  ),
                  items: fournisseurs
                      .map(
                        (fournisseur) => DropdownMenuItem(
                          value: fournisseur,
                          child: Text(fournisseur.nom),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _fournisseurSelectionne = value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Produits recus",
                        style: ThemeQuinca.titrePrincipal.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: "Ajouter une ligne",
                      onPressed: _validationEnCours ? null : _ajouterLigne,
                      icon: const Icon(Icons.add_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: ThemeQuinca.bleuPrincipal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _lignes.length,
                    itemBuilder: (context, index) {
                      final ligne = _lignes[index];
                      return _CarteLigneArrivage(
                        ligne: ligne,
                        produits: produits,
                        index: index,
                        onSupprimer: () => _supprimerLigne(index),
                        onChanged: () => setState(() {}),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 210,
                    child: BtnPrincipal(
                      texte: _validationEnCours
                          ? "Validation..."
                          : "Valider l'arrivage",
                      onPressed: _validerArrivage,
                      isLoading: _validationEnCours,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LigneArrivageForm {
  String? produitId;
  final TextEditingController quantiteCtrl = TextEditingController();

  void dispose() {
    quantiteCtrl.dispose();
  }
}

class _CarteLigneArrivage extends StatelessWidget {
  final _LigneArrivageForm ligne;
  final List<Produit> produits;
  final int index;
  final VoidCallback onSupprimer;
  final VoidCallback onChanged;

  const _CarteLigneArrivage({
    required this.ligne,
    required this.produits,
    required this.index,
    required this.onSupprimer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Produit? produitSelectionne;
    for (final produit in produits) {
      if (produit.id == ligne.produitId) {
        produitSelectionne = produit;
        break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ThemeQuinca.bleuPrincipal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${index + 1}",
                  style: ThemeQuinca.titrePrincipal.copyWith(
                    color: ThemeQuinca.bleuPrincipal,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Produit recu",
                  style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: onSupprimer,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: ThemeQuinca.rupture,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: ligne.produitId,
            isExpanded: true,
            decoration: _decorationArrivage(
              label: "Choisir le produit",
              icone: Icons.inventory_2_outlined,
            ),
            items: produits
                .map(
                  (produit) => DropdownMenuItem(
                    value: produit.id,
                    child: Text(
                      produit.nom,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              ligne.produitId = value;
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: ligne.quantiteCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _decorationArrivage(
                    label: produitSelectionne == null
                        ? "Quantite recue"
                        : "Quantite (${produitSelectionne.uniteVente})",
                    icone: Icons.add_box_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StockActuelArrivage(produit: produitSelectionne),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockActuelArrivage extends StatelessWidget {
  final Produit? produit;

  const _StockActuelArrivage({required this.produit});

  @override
  Widget build(BuildContext context) {
    final stock =
        produit == null ? "-" : "${produit!.quantite} ${produit!.uniteVente}";

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ThemeQuinca.fondGris,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warehouse_outlined,
            color: ThemeQuinca.bleuPrincipal,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stock actuel",
                  style: ThemeQuinca.corpsTexte.copyWith(fontSize: 11),
                ),
                Text(
                  stock,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _decorationArrivage({
  required String label,
  required IconData icone,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: ThemeQuinca.corpsTexte,
    prefixIcon: Icon(icone, color: ThemeQuinca.bleuPrincipal, size: 20),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: ThemeQuinca.bordure),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: ThemeQuinca.bordure),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: ThemeQuinca.bleuPrincipal,
        width: 1.5,
      ),
    ),
  );
}
