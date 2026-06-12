// lib/modules/produit/presentation/onglets/catalogue.dart

import 'package:flutter/material.dart';
import '../../../../coeur/theme/theme_quinca.dart';
import '../../../../coeur/composants/btn_principal.dart';
import '../../logique/stock_controller.dart';
import '../../data/produit.dart';
import '../../../auth/data/user.dart';

class CataloguePage extends StatefulWidget {
  final StockController controller;
  final User user;

  const CataloguePage({super.key, required this.controller, required this.user});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  // Liste pour stocker les contrôleurs de chaque ligne
  final List<Map<String, TextEditingController>> _lignes = [];
  final List<String> _categories = ["Général", "Plomberie", "Électricité", "Maçonnerie", "Peinture"];

  @override
  void initState() {
    super.initState();
    _ajouterLigne(); // On commence avec une ligne par défaut
  }

  void _ajouterLigne() {
    setState(() {
      _lignes.add({
        "nom": TextEditingController(),
        "ref": TextEditingController(),
        "cat": TextEditingController(text: _categories.first),
        "prixA": TextEditingController(),
        "prixV": TextEditingController(),
        "seuil": TextEditingController(text: "5"),
        "stock": TextEditingController(text: "0"),
      });
    });
  }

  void _supprimerLigne(int index) {
    if (_lignes.length > 1) {
      setState(() => _lignes.removeAt(index));
    }
  }

  void _enregistrerTout() {
    int ajoutes = 0;
    for (var ligne in _lignes) {
      String nom = ligne["nom"]!.text.trim();
      String ref = ligne["ref"]!.text.trim();
      if (nom.isNotEmpty && ref.isNotEmpty) {
        widget.controller.nouveauProduit(
          Produit(
            id: "PROD-${DateTime.now().microsecondsSinceEpoch}-${ajoutes}", // Génération d'un ID unique
            boutiqueId: widget.user.boutiqueId,
            nom: nom,
            reference: ref,
            categorie: ligne["cat"]!.text.isEmpty ? "Général" : ligne["cat"]!.text.trim(),
            quantite: int.tryParse(ligne["stock"]!.text) ?? 0,
            prixAchat: double.tryParse(ligne["prixA"]!.text) ?? 0,
            prixVente: double.tryParse(ligne["prixV"]!.text) ?? 0,
            seuilAlerte: int.tryParse(ligne["seuil"]!.text) ?? 5,
          ),
        );
        ajoutes++;
      }
    }
    if (ajoutes > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$ajoutes produits enregistrés au catalogue")));
      setState(() => _lignes.clear());
      _ajouterLigne();
    }
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: ThemeQuinca.bordure)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: TextField(controller: _lignes[index]["nom"], decoration: const InputDecoration(labelText: "Nom *", isDense: true))),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(controller: _lignes[index]["ref"], decoration: const InputDecoration(labelText: "Référence *", isDense: true))),
                            IconButton(onPressed: () => _supprimerLigne(index), icon: const Icon(Icons.remove_circle_outline, color: ThemeQuinca.rupture)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _lignes[index]["cat"]!.text,
                                decoration: const InputDecoration(labelText: "Catégorie", isDense: true),
                                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _lignes[index]["cat"]!.text = val!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(controller: _lignes[index]["prixA"], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "P. Achat", isDense: true))),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(controller: _lignes[index]["prixV"], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "P. Vente", isDense: true))),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: TextField(controller: _lignes[index]["seuil"], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Seuil Alerte", isDense: true))),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(controller: _lignes[index]["stock"], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock Initial", isDense: true))),
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
              Expanded(child: OutlinedButton.icon(onPressed: _ajouterLigne, icon: const Icon(Icons.add), label: const Text("Autre ligne"))),
              const SizedBox(width: 12),
              Expanded(child: BtnPrincipal(texte: "Tout enregistrer", onPressed: _enregistrerTout)),
            ],
          ),
        ],
      ),
    );
  }
}