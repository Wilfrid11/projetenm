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
          uniteVente: ligne["unite"]!.text.isEmpty
              ? "piece"
              : ligne["unite"]!.text,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _lignes.length,
              itemBuilder: (context, index) {
                final ligne = _lignes[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: ThemeQuinca.bordure),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ligne["nom"],
                                decoration: const InputDecoration(
                                  labelText: "Nom *",
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _supprimerLigne(index),
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: ThemeQuinca.rupture,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: ligne["cat"]!.text,
                                decoration: const InputDecoration(
                                  labelText: "Categorie",
                                  isDense: true,
                                ),
                                items: _categories
                                    .map(
                                      (categorie) => DropdownMenuItem(
                                        value: categorie,
                                        child: Text(
                                          categorie,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (valeur) {
                                  setState(() {
                                    ligne["cat"]!.text = valeur!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: ligne["unite"]!.text,
                                decoration: const InputDecoration(
                                  labelText: "Unite",
                                  isDense: true,
                                ),
                                items: _unitesVente
                                    .map(
                                      (unite) => DropdownMenuItem(
                                        value: unite,
                                        child: Text(
                                          unite,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (valeur) {
                                  setState(() {
                                    ligne["unite"]!.text = valeur!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ligne["prixA"],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "P. Achat *",
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: ligne["prixV"],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "P. Vente *",
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ligne["stock"],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Stock initial",
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: ligne["seuil"],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Seuil alerte",
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _enregistrement ? null : _ajouterLigne,
                  icon: const Icon(Icons.add),
                  label: const Text("Autre ligne"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BtnPrincipal(
                  texte: _enregistrement
                      ? "Enregistrement..."
                      : "Tout enregistrer",
                  onPressed: _enregistrerTout,
                  isLoading: _enregistrement,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
