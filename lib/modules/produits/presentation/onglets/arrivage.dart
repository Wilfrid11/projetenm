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
    return ListenableBuilder(
      listenable: Listenable.merge([widget.controller, _fournisseurController]),
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
              Text(
                "Produits recus",
                style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _validationEnCours ? null : _ajouterLigne,
                      icon: const Icon(Icons.add),
                      label: const Text("Ajouter une ligne"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BtnPrincipal(
                      texte: _validationEnCours
                          ? "Validation..."
                          : "Valider l'arrivage",
                      onPressed: _validerArrivage,
                      isLoading: _validationEnCours,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeQuinca.bordure),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: ligne.produitId,
                    decoration: const InputDecoration(
                      labelText: "Produit",
                      isDense: true,
                    ),
                    items: produits
                        .map(
                          (produit) => DropdownMenuItem(
                            value: produit.id,
                            child: Text(produit.nom),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      ligne.produitId = value;
                      onChanged();
                    },
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ligne.quantiteCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: produitSelectionne == null
                          ? "Quantite recue"
                          : "Quantite (${produitSelectionne.uniteVente})",
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    produitSelectionne == null
                        ? "Stock actuel : -"
                        : "Stock actuel : ${produitSelectionne.quantite} ${produitSelectionne.uniteVente}",
                    style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12),
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
