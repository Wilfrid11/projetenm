// lib/modules/produits/presentation/onglets/catalogue.dart

import 'package:flutter/material.dart';

import '../../../../coeur/composants/btn_principal.dart';
import '../../../../coeur/theme/theme_quinca.dart';
import '../../../auth/data/user.dart';
import '../../data/produit.dart';
import '../../logique/stock_controller.dart';

class CataloguePage extends StatefulWidget {
  final StockController controller;
  final User user;

  const CataloguePage({
    super.key,
    required this.controller,
    required this.user,
  });

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final List<Map<String, TextEditingController>> _lignes = [];
  final List<String> _categories = const [
    "General",
    "Plomberie",
    "Electricite",
    "Maconnerie",
    "Peinture",
  ];
  final List<String> _unitesVente = const [
    "piece",
    "boite",
    "sachet",
    "metre",
    "kg",
    "litre",
    "sac",
    "paquet",
    "rouleau",
    "barre",
  ];

  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    _ajouterLigne();
  }

  @override
  void dispose() {
    for (final ligne in _lignes) {
      _detruireControleurs(ligne);
    }
    super.dispose();
  }

  void _ajouterLigne() {
    setState(() {
      _lignes.add({
        "nom": TextEditingController(),
        "cat": TextEditingController(text: _categories.first),
        "unite": TextEditingController(text: _unitesVente.first),
        "prixA": TextEditingController(),
        "prixV": TextEditingController(),
        "seuil": TextEditingController(text: "5"),
        "stock": TextEditingController(text: "0"),
      });
    });
  }

  void _supprimerLigne(int index) {
    if (_lignes.length <= 1) return;

    _detruireControleurs(_lignes[index]);
    setState(() => _lignes.removeAt(index));
  }

  Future<void> _enregistrerTout() async {
    if (_enregistrement) return;

    final produits = <Produit>[];

    for (var i = 0; i < _lignes.length; i++) {
      final ligne = _lignes[i];
      final nom = ligne["nom"]!.text.trim();
      final prixAchat = double.tryParse(ligne["prixA"]!.text.trim());
      final prixVente = double.tryParse(ligne["prixV"]!.text.trim());

      if (nom.isEmpty) continue;

      if (prixAchat == null || prixVente == null || prixVente <= 0) {
        _afficherErreur(
          "Ligne ${i + 1} : prix achat et prix vente valides requis.",
        );
        return;
      }

      produits.add(
        Produit(
          id: "",
          boutiqueId: widget.user.boutiqueId,
          // Reference automatique : le depot Firebase genere la valeur finale.
          reference: "",
          nom: nom,
          categorie:
              ligne["cat"]!.text.isEmpty ? "General" : ligne["cat"]!.text,
          uniteVente:
              ligne["unite"]!.text.isEmpty ? "piece" : ligne["unite"]!.text,
          quantite: int.tryParse(ligne["stock"]!.text.trim()) ?? 0,
          prixAchat: prixAchat,
          prixVente: prixVente,
          seuilAlerte: int.tryParse(ligne["seuil"]!.text.trim()) ?? 5,
          actif: true,
        ),
      );
    }

    if (produits.isEmpty) {
      _afficherErreur("Ajoutez au moins un produit valide.");
      return;
    }

    setState(() => _enregistrement = true);
    final ajoutes = await widget.controller.ajouterProduits(produits);
    if (!mounted) return;
    setState(() => _enregistrement = false);

    if (ajoutes <= 0) {
      _afficherErreur(
        widget.controller.erreurProduits ??
            "Aucun produit n'a pu etre enregistre.",
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$ajoutes produits enregistres au catalogue")),
    );

    _viderLignes();
    _ajouterLigne();
  }

  void _viderLignes() {
    for (final ligne in _lignes) {
      _detruireControleurs(ligne);
    }
    setState(() => _lignes.clear());
  }

  void _detruireControleurs(Map<String, TextEditingController> ligne) {
    for (final controller in ligne.values) {
      controller.dispose();
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeQuinca.rupture,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        foregroundColor: Colors.white,
        title: const Text("Catalogue"),
        actions: [
          IconButton(
            tooltip: "Ajouter un produit",
            onPressed: _enregistrement ? null : _ajouterLigne,
            icon: const Icon(Icons.add_rounded, size: 30),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _EnteteCatalogue(
              nombreProduits: _lignes.length,
              onAjouter: _enregistrement ? null : _ajouterLigne,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                itemCount: _lignes.length,
                itemBuilder: (context, index) {
                  return _CarteFormulaireProduit(
                    index: index,
                    ligne: _lignes[index],
                    categories: _categories,
                    unitesVente: _unitesVente,
                    peutSupprimer: _lignes.length > 1,
                    onSupprimer: () => _supprimerLigne(index),
                    onDropdownChange: () => setState(() {}),
                  );
                },
              ),
            ),
            _BarreActionsCatalogue(
              enregistrement: _enregistrement,
              onEnregistrer: _enregistrerTout,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnteteCatalogue extends StatelessWidget {
  final int nombreProduits;
  final VoidCallback? onAjouter;

  const _EnteteCatalogue({
    required this.nombreProduits,
    required this.onAjouter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ThemeQuinca.bleuPrincipal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.playlist_add_rounded,
              color: ThemeQuinca.bleuPrincipal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ajouter au catalogue",
                  style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 3),
                Text(
                  "$nombreProduits produit(s) en preparation",
                  style: ThemeQuinca.corpsTexte,
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: "Ajouter un produit",
            onPressed: onAjouter,
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              backgroundColor: ThemeQuinca.bleuPrincipal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteFormulaireProduit extends StatelessWidget {
  final int index;
  final Map<String, TextEditingController> ligne;
  final List<String> categories;
  final List<String> unitesVente;
  final bool peutSupprimer;
  final VoidCallback onSupprimer;
  final VoidCallback onDropdownChange;

  const _CarteFormulaireProduit({
    required this.index,
    required this.ligne,
    required this.categories,
    required this.unitesVente,
    required this.peutSupprimer,
    required this.onSupprimer,
    required this.onDropdownChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
              Expanded(
                child: Text(
                  "Produit ${index + 1}",
                  style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 17),
                ),
              ),
              IconButton(
                tooltip: "Retirer cette ligne",
                onPressed: peutSupprimer ? onSupprimer : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: peutSupprimer
                      ? ThemeQuinca.rupture
                      : ThemeQuinca.texteSecondaire,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ChampCatalogue(
            controller: ligne["nom"]!,
            label: "Nom du produit *",
            icone: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DropdownCatalogue(
                  valeur: ligne["cat"]!.text,
                  label: "Categorie",
                  icone: Icons.category_outlined,
                  options: categories,
                  onChanged: (valeur) {
                    ligne["cat"]!.text = valeur;
                    onDropdownChange();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropdownCatalogue(
                  valeur: ligne["unite"]!.text,
                  label: "Unite",
                  icone: Icons.straighten_outlined,
                  options: unitesVente,
                  onChanged: (valeur) {
                    ligne["unite"]!.text = valeur;
                    onDropdownChange();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChampCatalogue(
                  controller: ligne["prixA"]!,
                  label: "Prix achat *",
                  icone: Icons.shopping_bag_outlined,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChampCatalogue(
                  controller: ligne["prixV"]!,
                  label: "Prix vente *",
                  icone: Icons.sell_outlined,
                  type: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChampCatalogue(
                  controller: ligne["stock"]!,
                  label: "Stock initial",
                  icone: Icons.numbers_outlined,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChampCatalogue(
                  controller: ligne["seuil"]!,
                  label: "Seuil alerte",
                  icone: Icons.warning_amber_rounded,
                  type: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChampCatalogue extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icone;
  final TextInputType type;

  const _ChampCatalogue({
    required this.controller,
    required this.label,
    required this.icone,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: _decorationCatalogue(label: label, icone: icone),
    );
  }
}

class _DropdownCatalogue extends StatelessWidget {
  final String valeur;
  final String label;
  final IconData icone;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _DropdownCatalogue({
    required this.valeur,
    required this.label,
    required this.icone,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: valeur,
      isExpanded: true,
      decoration: _decorationCatalogue(label: label, icone: icone),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
                style: ThemeQuinca.corpsTexte.copyWith(
                  color: ThemeQuinca.texteFonce,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (valeur) {
        if (valeur != null) onChanged(valeur);
      },
    );
  }
}

class _BarreActionsCatalogue extends StatelessWidget {
  final bool enregistrement;
  final VoidCallback onEnregistrer;

  const _BarreActionsCatalogue({
    required this.enregistrement,
    required this.onEnregistrer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ThemeQuinca.bordure)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 190,
          child: BtnPrincipal(
            texte: enregistrement ? "Enregistrement..." : "Enregistrer",
            onPressed: onEnregistrer,
            isLoading: enregistrement,
          ),
        ),
      ),
    );
  }
}

InputDecoration _decorationCatalogue({
  required String label,
  required IconData icone,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: ThemeQuinca.corpsTexte,
    prefixIcon: Icon(icone, color: ThemeQuinca.bleuPrincipal, size: 20),
    filled: true,
    fillColor: ThemeQuinca.fondGris,
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
      borderSide:
          const BorderSide(color: ThemeQuinca.bleuPrincipal, width: 1.5),
    ),
  );
}
