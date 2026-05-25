// lib/modules/produit/presentation/onglets/arrivage.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logique/stock_controller.dart';
import '../../data/produit.dart';

class ArrivageScreen extends StatefulWidget {
  final StockController controller;

  const ArrivageScreen({super.key, required this.controller});

  @override
  State<ArrivageScreen> createState() => _ArrivageScreenState();
}

class _ArrivageScreenState extends State<ArrivageScreen> {
  @override
  Widget build(BuildContext context) {
    // On écoute le contrôleur pour avoir les produits à jour
    final listeProduits = widget.controller.produits;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(
          "Arrivage / Entrée Stock",
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= PARCOURS B : ARTICLE INÉDIT =================
            Card(
              elevation: 0,
              color: const Color(0xFFFFF7ED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFFEDD5)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE4E6),
                  child: Icon(Icons.add_box_outlined, color: Color(0xFFF97316)),
                ),
                title: Text(
                  "Parcours B : Nouvel article Camion",
                  style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFFC2410C)),
                ),
                subtitle: const Text("L'article n'existe pas encore. Créer la fiche et ajouter le stock."),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFF97316)),
                onTap: () => _ouvrirFormulaireInedit(context),
              ),
            ),
            const SizedBox(height: 24),
            
            // ================= PARCOURS A : SELECTION EXISTANTE =================
            Text(
              "Parcours A : Sélectionner l'article reçu",
              style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: listeProduits.isEmpty
                  ? const Center(child: Text("Aucun produit disponible."))
                  : ListView.builder(
                      itemCount: listeProduits.length,
                      itemBuilder: (context, index) {
                        final prod = listeProduits[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: prod.couleurStatut.withOpacity(0.1),
                              child: Icon(Icons.inventory_2_outlined, color: prod.couleurStatut, size: 18),
                            ),
                            title: Text(prod.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text("Stock actuel : ${prod.quantite} u"),
                            trailing: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1A3B8B)),
                            onTap: () => _ouvrirSaisieQuantiteExistante(context, prod),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // BOÎTE DE DIALOGUE : PARCOURS A (Ajout sur produit existant)
  void _ouvrirSaisieQuantiteExistante(BuildContext contexte, Produit produit) {
    final TextEditingController qteController = TextEditingController();

    showDialog(
      context: contexte,
      builder: (contexte) => AlertDialog(
        title: Text("Arrivage : ${produit.nom}", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: qteController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Quantité reçue (Unités) *",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexte),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3B8B)),
            onPressed: () {
              int? qte = int.tryParse(qteController.text);
              if (qte != null && qte > 0) {
                // On utilise le contrôleur pour modifier la donnée réelle
                widget.controller.enregistrerArrivage(produit.reference, qte, "Gérant");
                Navigator.pop(contexte);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Stock mis à jour : +$qte ${produit.nom}")),
                );
              }
            },
            child: const Text("Valider", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // FORMULAIRE MODAL : PARCOURS B (Création d'une fiche + injection stock immédiat)
  void _ouvrirFormulaireInedit(BuildContext contexte) {
    final nomCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final prixACtrl = TextEditingController();
    final prixVCtrl = TextEditingController();
    final qteCtrl = TextEditingController();
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
            right: 16
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Fiche Nouvel Arrivage (Inédit)", 
                  style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFF97316))
                ),
                const SizedBox(height: 16),
                TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: "Nom de l'article *", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: refCtrl, decoration: const InputDecoration(labelText: "Référence / Code Barre *", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: prixACtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Prix Achat *", border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: prixVCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Prix Vente *", border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: qteCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantité livrée *", border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: seuilCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Seuil d'alerte *", border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
                    onPressed: () {
                      if (nomCtrl.text.isNotEmpty && refCtrl.text.isNotEmpty && qteCtrl.text.isNotEmpty) {
                        int initialeQte = int.tryParse(qteCtrl.text) ?? 0;
                        
                        // 1. On crée d'abord la fiche technique dans notre liste globale
                        widget.controller.creerFicheCatalogue(
                          Produit(
                            nom: nomCtrl.text,
                            reference: refCtrl.text,
                            categorie: "Inédit",
                            quantite: initialeQte, // Injecte directement la quantité reçue
                            prixAchat: double.tryParse(prixACtrl.text) ?? 0,
                            prixVente: double.tryParse(prixVCtrl.text) ?? 0,
                            seuilAlerte: int.tryParse(seuilCtrl.text) ?? 5,
                          ),
                        );

                        // 2. On ajoute une trace propre dans l'historique de suivi
                        widget.controller.historique.insert(0, {
                          'produit': nomCtrl.text,
                          'quantite': initialeQte,
                          'auteur': 'Gérant (Parcours B)',
                          'date': DateTime.now().toString().substring(0, 16),
                        });

                        Navigator.pop(contexte);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nouvel article enregistré et stocké !")),
                        );
                      }
                    },
                    child: const Text("Valider le bon d'entrée", style: TextStyle(color: Colors.white)),
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