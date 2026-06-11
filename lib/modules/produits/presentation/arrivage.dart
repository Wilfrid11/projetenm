import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../historique/data/historique_models.dart';
import '../logique/stock_controller.dart';
import '../data/produit.dart';

class ArrivagePage extends StatefulWidget {
  final StockController controller;
  final String auteur;

  const ArrivagePage({super.key, required this.controller, required this.auteur});

  @override
  State<ArrivagePage> createState() => _ArrivagePageState();
}

class _ArrivagePageState extends State<ArrivagePage> {
  final _fournisseurController = TextEditingController();
  final List<LigneEntree> _lignesEnCours = [];
  
  Produit? _produitSelectionne;
  final _qteController = TextEditingController();

  void _ajouterLigne() {
    if (_produitSelectionne != null && _qteController.text.isNotEmpty) {
      setState(() {
        _lignesEnCours.add(LigneEntree(
          nomProduit: _produitSelectionne!.nom,
          categorie: _produitSelectionne!.categorie,
          quantiteRecue: int.parse(_qteController.text),
        ));
        _qteController.clear();
        _produitSelectionne = null;
      });
    }
  }

  void _validerTout() {
    if (_fournisseurController.text.isEmpty || _lignesEnCours.isEmpty) return;

    final arrivage = EntreeFournisseur(
      id: "ARR-${DateTime.now().millisecondsSinceEpoch}",
      fournisseur: _fournisseurController.text.trim(),
      dateArrivage: "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} à ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      auteur: widget.auteur,
      lignes: List.from(_lignesEnCours),
    );

    widget.controller.validerArrivage(arrivage);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Arrivage enregistré avec succès !")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Réception Arrivage"), backgroundColor: ThemeQuinca.bleuPrincipal, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fournisseurController,
              decoration: const InputDecoration(labelText: "Nom du Fournisseur", prefixIcon: Icon(Icons.business_rounded)),
            ),
            const Divider(height: 32),
            
            // Zone ajout produit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButton<Produit>(
                    isExpanded: true,
                    hint: const Text("Sélectionner produit"),
                    value: _produitSelectionne,
                    items: widget.controller.produits.map((p) => DropdownMenuItem(value: p, child: Text(p.nom))).toList(),
                    onChanged: (val) => setState(() => _produitSelectionne = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _qteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Qté"),
                  ),
                ),
                IconButton(onPressed: _ajouterLigne, icon: const Icon(Icons.add_circle, color: ThemeQuinca.succes)),
              ],
            ),
            
            const SizedBox(height: 16),
            Text("Produits à réceptionner :", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
            
            Expanded(
              child: ListView.builder(
                itemCount: _lignesEnCours.length,
                itemBuilder: (context, index) {
                  final ligne = _lignesEnCours[index];
                  return ListTile(
                    title: Text(ligne.nomProduit),
                    subtitle: Text(ligne.categorie),
                    trailing: Text("+ ${ligne.quantiteRecue}", style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeQuinca.succes)),
                    onLongPress: () => setState(() => _lignesEnCours.removeAt(index)),
                  );
                },
              ),
            ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _lignesEnCours.isEmpty ? null : _validerTout,
                style: ElevatedButton.styleFrom(backgroundColor: ThemeQuinca.bleuPrincipal),
                child: const Text("Valider l'entrée en stock", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}