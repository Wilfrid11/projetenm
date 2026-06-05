// lib/modules/produit/presentation/onglets/arrivage.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../coeur/theme/theme_quinca.dart'; // Import de ton fichier de thème
import '../../logique/stock_controller.dart';
import '../../data/produit.dart';

class ArrivagePage extends StatefulWidget {
  final StockController controller;

  const ArrivagePage({
    super.key, 
    required this.controller,
  });

  @override
  State<ArrivagePage> createState() => _ArrivagePageState();
}

class _ArrivagePageState extends State<ArrivagePage> {
  // Petite fonction locale pour déterminer la couleur de l'icône selon le niveau de stock
  Color _obtenirCouleurStock(Produit prod) {
    if (prod.quantite == 0) {
      return ThemeQuinca.rupture; // Rouge si rupture
    } else if (prod.quantite <= prod.seuilAlerte) {
      return ThemeQuinca.alerte; // Orange si alerte critique
    }
    return ThemeQuinca.succes; // Vert si stock suffisant
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: ThemeQuinca.texteFonce),
        title: Text(
          "Arrivage / Entrée Stock",
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeQuinca.texteFonce),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final listeProduits = widget.controller.produits;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= PARCOURS B : ARTICLE INÉDIT =================
                Card(
                  elevation: 0,
                  color: ThemeQuinca.alerte.withValues(alpha: 0.08), // Utilisation de alerte (Orange)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: ThemeQuinca.alerte.withValues(alpha: 0.2)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ThemeQuinca.alerte.withValues(alpha: 0.15),
                      child: const Icon(Icons.add_box_outlined, color: ThemeQuinca.alerte),
                    ),
                    title: Text(
                      "Nouvel article",
                      style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: ThemeQuinca.alerte),
                    ),
                    subtitle: const Text("L'article n'existe pas encore. Créer la fiche et ajouter le stock."),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ThemeQuinca.alerte),
                    onTap: () => _ouvrirFormulaireInedit(context),
                  ),
                ),
                const SizedBox(height: 24),
                
                // ================= PARCOURS A : SELECTION EXISTANTE =================
                Text(
                  " Sélectionner l'article reçu",
                  style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeQuinca.texteFonce),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: listeProduits.isEmpty
                      ? const Center(child: Text("Aucun produit disponible."))
                      : ListView.builder(
                          itemCount: listeProduits.length,
                          itemBuilder: (context, index) {
                            final prod = listeProduits[index];
                            // Détermination de la couleur selon l'état du produit
                            final couleurStatut = _obtenirCouleurStock(prod);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ThemeQuinca.bordure),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  // Couleur dynamique (Vert, Orange ou Rouge) selon le stock réel !
                                  backgroundColor: couleurStatut.withValues(alpha: 0.1),
                                  child: Icon(Icons.inventory_2_outlined, color: couleurStatut, size: 18),
                                ),
                                title: Text(prod.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ThemeQuinca.texteFonce)),
                                subtitle: Text("Stock actuel : ${prod.quantite} u", style: const TextStyle(color: ThemeQuinca.texteSecondaire)),
                                trailing: const Icon(Icons.add_circle_outline_rounded, color: ThemeQuinca.bleuPrincipal),
                                onTap: () => _ouvrirSaisieQuantiteExistante(context, prod),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // BOÎTE DE DIALOGUE : PARCOURS A (Ajout sur produit existant)
  void _ouvrirSaisieQuantiteExistante(BuildContext contexte, Produit produit) {
    final TextEditingController qteController = TextEditingController();

    showDialog(
      context: contexte,
      builder: (contexte) => AlertDialog(
        title: Text("Arrivage : ${produit.nom}", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16, color: ThemeQuinca.texteFonce)),
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
            child: const Text("Annuler", style: TextStyle(color: ThemeQuinca.texteSecondaire)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeQuinca.bleuPrincipal),
            onPressed: () {
              int? qte = int.tryParse(qteController.text);
              if (qte != null && qte > 0) {
                widget.controller.incrementerStock(produit.id, qte);
                Navigator.pop(contexte);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Stock mis à jour : +$qte ${produit.nom}")),
                );
              }
            },
            child: const Text("Valider", style: TextStyle(color: ThemeQuinca.texteInverse)),
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
                  style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeQuinca.alerte)
                ),
                const SizedBox(height: 16),
                TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: "Nom de l'article *", border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: refCtrl, decoration: const InputDecoration(labelText: "Référence ", border: OutlineInputBorder())),
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
                    style: ElevatedButton.styleFrom(backgroundColor: ThemeQuinca.bleuPrincipal), // Bouton principal en Bleu
                    onPressed: () {
                      if (nomCtrl.text.isNotEmpty && refCtrl.text.isNotEmpty && qteCtrl.text.isNotEmpty) {
                        int initialeQte = int.tryParse(qteCtrl.text) ?? 0;
                        
                        widget.controller.nouveauProduit(
                          Produit(
                            id: refCtrl.text.trim(),
                            nom: nomCtrl.text.trim(),
                            reference: refCtrl.text.trim(),
                            categorie: "Inédit",
                            quantite: initialeQte, 
                            prixAchat: double.tryParse(prixACtrl.text) ?? 0,
                            prixVente: double.tryParse(prixVCtrl.text) ?? 0,
                            seuilAlerte: int.tryParse(seuilCtrl.text) ?? 5,
                          ),
                        );

                        Navigator.pop(contexte);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nouvel article enregistré et stocké !")),
                        );
                      }
                    },
                    child: const Text("Valider le bon d'entrée", style: TextStyle(color: ThemeQuinca.texteInverse)),
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