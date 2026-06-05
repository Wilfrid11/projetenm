// lib/modules/produit/presentation/onglets/catalogue.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logique/stock_controller.dart';
import '../../data/produit.dart';
import '../../../auth/data/user.dart';

class CataloguePage extends StatelessWidget {
  final StockController controller;
  final User user;

  const CataloguePage({super.key, required this.controller, required this.user});

  @override
  Widget build(BuildContext context) {
    bool estAdmin = user.role == "admin" || user.role == "gerant";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(
          "Dictionnaire Catalogue",
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        actions: [
          if (estAdmin)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF1A3B8B), size: 28),
              onPressed: () => _ouvrirFormulaireCreation(context),
            )
        ],
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final listeProduits = controller.produits;

          if (listeProduits.isEmpty) {
            return const Center(child: Text("Aucun article dans le catalogue."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listeProduits.length,
            itemBuilder: (context, index) {
              final prod = listeProduits[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prod.nom, style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      "Réf: ${prod.reference} | Catégorie: ${prod.categorie}", 
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Prix Vente: ${prod.prixVente.toInt()} F", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A3B8B)),
                        ),
                        Text(
                          "Seuil Alerte: ${prod.seuilAlerte} u", 
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _ouvrirFormulaireCreation(BuildContext contexte) {
    final nomCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final prixACtrl = TextEditingController();
    final prixVCtrl = TextEditingController();
    final seuilCtrl = TextEditingController();

    showModalBottomSheet(
      context: contexte,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (contexte) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(contexte).viewInsets.bottom, 
            top: 20, 
            left: 16, 
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Ajouter au Catalogue", style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: "Nom de l'article *", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: refCtrl, decoration: const InputDecoration(labelText: "Référence unique *", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: prixACtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Prix Achat *", border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: prixVCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Prix Vente *", border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: seuilCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Seuil d'alerte *", border: OutlineInputBorder())),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3B8B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (nomCtrl.text.isNotEmpty && refCtrl.text.isNotEmpty) {
                        controller.nouveauProduit(
                          Produit(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            nom: nomCtrl.text.trim(),
                            reference: refCtrl.text.trim(),
                            categorie: "Général",
                            quantite: 0,
                            prixAchat: double.tryParse(prixACtrl.text) ?? 0,
                            prixVente: double.tryParse(prixVCtrl.text) ?? 0,
                            seuilAlerte: int.tryParse(seuilCtrl.text) ?? 5,
                          ),
                        );
                        Navigator.pop(contexte);
                      }
                    },
                    child: const Text("Enregistrer la fiche", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}