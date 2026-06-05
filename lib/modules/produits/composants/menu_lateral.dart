// lib/modules/produit/presentation/composants/menu_lateral.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../logique/stock_controller.dart';
import '../presentation/onglets/catalogue.dart'; // Correction chemin d'import
import '../presentation/onglets/arrivage.dart';  // Correction chemin d'import
import '../../auth/data/user.dart'; // Import nécessaire pour passer l'utilisateur au CataloguePage

class MenuLateral extends StatelessWidget {
  final StockController stockController;
  final User user; // 👈 1. Ajout de la propriété user

  // 👈 2. Mise à jour du constructeur pour exiger l'utilisateur
  const MenuLateral({
    super.key, 
    required this.stockController,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du menu
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            color: ThemeQuinca.bleuPrincipal,
            width: double.infinity,
            child: Text(
              "Menu Stock",
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeQuinca.texteInverse,
              ),
            ),
          ),

          // Option 1 : Catalogue
          ListTile(
            leading: const Icon(
              Icons.assignment_outlined,
              color: ThemeQuinca.bleuPrincipal,
            ),
            title: Text(
              "Catalogue",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ThemeQuinca.texteFonce,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CataloguePage(
                    controller: stockController,
                    user: user, // 👈 3. Passage de l'utilisateur reçu au CataloguePage
                  ),
                ),
              );
            },
          ),

          // Option 2 : Arrivage
          ListTile(
            leading: const Icon(
              Icons.local_shipping_outlined,
              color: ThemeQuinca.bleuPrincipal,
            ),
            title: Text(
              "Arrivage",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ThemeQuinca.texteFonce,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArrivagePage(
                    controller: stockController, // Parfaitement aligné sur le constructeur d'ArrivagePage
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}