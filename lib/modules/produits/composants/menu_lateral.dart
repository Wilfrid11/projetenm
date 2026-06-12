// lib/modules/produit/presentation/composants/menu_lateral.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quinca_pro/modules/produits/presentation/onglets/catalogue.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../auth/data/user.dart';
import '../logique/stock_controller.dart';
import '../../produits/presentation/onglets/historique_entrees.dart'; // Import pour la page d'historique des entrées
import '../../produits/presentation/onglets/arrivage.dart'; // 👈 Ajoutez cet import
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
                    controller: stockController,
                    user: user, // On passe l'objet User complet
                    // Note: L'ancienne page d'arrivage (onglets/arrivage.dart) est maintenant obsolète.
                    // Elle peut être supprimée si elle n'est plus utilisée ailleurs.
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF1A3B8B)),
            title: const Text("Historique des Entrées", style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context); // 1. Ferme d'abord le menu de côté
              
              // 2. Redirige vers la page d'historique des entrées
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoriqueEntreesPage(
                    controller: stockController, // On lui passe le contrôleur requis
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