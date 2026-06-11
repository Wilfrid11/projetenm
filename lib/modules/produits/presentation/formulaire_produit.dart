import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../data/produit.dart';
import '../logique/stock_controller.dart';

class FormulaireProduitPage extends StatefulWidget {
  final StockController controller;
  final Produit? produitExistant; // Si nul, on est en mode "Ajout"

  const FormulaireProduitPage({super.key, required this.controller, this.produitExistant});

  @override
  State<FormulaireProduitPage> createState() => _FormulaireProduitPageState();
}

class _FormulaireProduitPageState extends State<FormulaireProduitPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _refController;
  late TextEditingController _prixAchatController;
  late TextEditingController _prixVenteController;
  late TextEditingController _seuilController;
  late TextEditingController _qteController;
  
  String _categorieChoisie = "Maçonnerie";
  final List<String> _categories = ["Maçonnerie", "Électricité", "Plomberie", "Quincaillerie", "Peinture", "Divers"];

  @override
  void initState() {
    super.initState();
    final p = widget.produitExistant;
    _nomController = TextEditingController(text: p?.nom ?? "");
    _refController = TextEditingController(text: p?.reference ?? "");
    _prixAchatController = TextEditingController(text: p?.prixAchat.toString() ?? "");
    _prixVenteController = TextEditingController(text: p?.prixVente.toString() ?? "");
    _seuilController = TextEditingController(text: p?.seuilAlerte.toString() ?? "5");
    _qteController = TextEditingController(text: p?.quantite.toString() ?? "0");
    if (p != null) _categorieChoisie = p.categorie;
  }

  void _enregistrer() {
    if (_formKey.currentState!.validate()) {
      final nouveau = Produit(
        id: widget.produitExistant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        reference: _refController.text.trim(),
        nom: _nomController.text.trim(),
        categorie: _categorieChoisie,
        quantite: int.tryParse(_qteController.text) ?? 0,
        prixAchat: double.tryParse(_prixAchatController.text) ?? 0.0,
        prixVente: double.tryParse(_prixVenteController.text) ?? 0.0,
        seuilAlerte: int.tryParse(_seuilController.text) ?? 5,
      );

      if (widget.produitExistant == null) {
        widget.controller.nouveauProduit(nouveau);
      } else {
        widget.controller.modifierProduit(nouveau);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produitExistant == null ? "Nouveau Produit" : "Modifier Produit"),
        backgroundColor: ThemeQuinca.bleuPrincipal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField("Nom du produit", _nomController, Icons.label_outline),
              _buildField("Référence (ex: CIM-32)", _refController, Icons.qr_code_scanner),
              
              DropdownButtonFormField<String>(
                value: _categorieChoisie,
                decoration: _inputDecoration("Catégorie", Icons.category_outlined),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _categorieChoisie = val!),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildField("Prix Achat", _prixAchatController, Icons.download, num: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField("Prix Vente", _prixVenteController, Icons.sell_outlined, num: true)),
                ],
              ),
              
              Row(
                children: [
                  Expanded(child: _buildField("Stock Initial", _qteController, Icons.inventory_2_outlined, num: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField("Seuil d'alerte", _seuilController, Icons.notifications_active_outlined, num: true)),
                ],
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _enregistrer,
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeQuinca.bleuPrincipal),
                  child: Text("Enregistrer le produit", style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool num = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(label, icon),
        validator: (v) => (v == null || v.isEmpty) ? "Requis" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: ThemeQuinca.bleuPrincipal, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}