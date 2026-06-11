// lib/modules/dashboard/presentation/role.dart

import 'package:flutter/material.dart';
import '../../../coeur/theme/theme_quinca.dart'; // ◄ Centralisation de ta charte graphique
import '../../auth/data/user.dart';
import '../../produits/logique/stock_controller.dart'; 
import '../../ventes/logique/vente_controller.dart';
import '../../produits/presentation/produit.dart';
import '../../ventes/presentation/vente.dart';
import '../../ventes/presentation/historique_ventes.dart'; // ◄ AJOUTÉ : Importation indispensable pour HistoriqueVentesPage
import 'admin.dart';
import 'gerant.dart';

class RolePage extends StatefulWidget {
  final User user;
  final StockController stockController;
  final VenteController venteController;

  const RolePage({
    super.key,
    required this.user,
    required this.stockController,
    required this.venteController,
  });

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  int _currentIndex = 0;

  /// Routeur interne : Évite les ternaires imbriqués complexes et lève les erreurs de parenthèses
  Widget _recupererPage() {
    switch (_currentIndex) {
      case 0:
        // Filtrage de la page d'accueil selon le rôle de l'utilisateur connecté
        if (widget.user.role == 'admin') {
          return DashboardAdmin(
            stockController: widget.stockController,
            venteController: widget.venteController,
          );
        } else {
          // Ajusté selon tes commentaires : GerantPage prend uniquement user et stockController
          return GerantPage(
            user: widget.user,
            stockController: widget.stockController,
            venteController: widget.venteController,
            onAllerAuxVentes: () => setState(() => _currentIndex = 2), // Index des ventes
          );
        }
      case 1:
        return ProduitPage(
          stockController: widget.stockController,
          user: widget.user,
        );
      case 2:
        return VentePage(
          venteController: widget.venteController,
        );
      case 3:
        return HistoriqueVentesPage(
          controller: widget.venteController, // ◄ Raccordé avec le nom de ton paramètre requis
        );
      default:
        return Center(
          child: Text("Page non trouvée", style: TextStyle(color: ThemeQuinca.texteFonce)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris, // ◄ Raccord avec ton design épuré (ex: 0xFFF8FAFC)
      body: _recupererPage(), // ◄ Injection propre de la page courante
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: ThemeQuinca.bleuPrincipal, // ◄ Unifié sur ton Bleu-Pro de référence
        unselectedItemColor: ThemeQuinca.texteSecondaire, // ◄ (ex: 0xFF64748B)
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: "Produits",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: "Ventes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            activeIcon: Icon(Icons.history_rounded),
            label: "Historique",
          ),
        ],
      ),
    );
  }
}