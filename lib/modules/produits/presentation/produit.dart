import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logique/stock_controller.dart';
import '../../auth/data/user.dart';
import './onglets/catalogue.dart';
import './onglets/arrivage.dart';
import './onglets/historique.dart';

class ProduitsScreen extends StatefulWidget {
  final User utilisateurConnecte;
  final StockController stockController; // On reçoit le contrôleur

  const ProduitsScreen({
    super.key, 
    required this.utilisateurConnecte, 
    required this.stockController
  });

  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder( // ÉCOUTE LE MOTEUR LOGIQUE EN TEMPS RÉEL
      listenable: widget.stockController,
      builder: (context, _) {
        final liste = widget.stockController.produits;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text("Gestion du Stock", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0.5,
          ),
          drawer: _buildDrawer(context),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liste.length,
            itemBuilder: (context, index) {
              final prod = liste[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: prod.couleurStatut),
                  title: Text(prod.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Réf: ${prod.reference}"),
                  trailing: Text("${prod.quantite} u", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1A3B8B)),
            child: Center(child: Text("MENU STOCK", style: TextStyle(color: Colors.white, fontSize: 20))),
          ),
          _itemMenu(context, "Option 1 : Catalogue", Icons.book, () => CatalogueScreen(controller: widget.stockController, user: widget.utilisateurConnecte)),
          _itemMenu(context, "Option 2 : Arrivage", Icons.local_shipping, () => ArrivageScreen(controller: widget.stockController)),
          _itemMenu(context, "Option 3 : Historique", Icons.history, () => HistoriqueScreen(controller: widget.stockController)),
        ],
      ),
    );
  }

  Widget _itemMenu(BuildContext context, String titre, IconData icone, Widget Function() page) {
    return ListTile(
      leading: Icon(icone),
      title: Text(titre),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page()));
      },
    );
  }
}