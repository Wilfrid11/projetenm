// lib/modules/dashboard/presentation/role.dart

import 'package:flutter/material.dart';
import '../../../coeur/theme/theme_quinca.dart'; // ◄ Centralisation de ta charte graphique
import '../../auth/data/user.dart';
import '../../auth/logique/hook.dart';
import '../../auth/presentation/login.dart';
import '../../produits/logique/stock_controller.dart'; 
import '../../ventes/logique/vente_controller.dart';
import '../../auth/logique/user_controller.dart';
import '../../produits/presentation/produit.dart';
import '../../ventes/presentation/vente.dart';
import '../../ventes/presentation/historique_ventes.dart'; // ◄ AJOUTÉ : Importation indispensable pour HistoriqueVentesPage
import '../../parametres/presentation/mon_profil_page.dart';
import '../../parametres/presentation/parametres_page.dart';
import 'admin.dart';
import 'gerant.dart';

class RolePage extends StatefulWidget {
  final User user;
  final StockController stockController;
  final VenteController venteController;
  final UserController userController;
  final HookAuth authHook;

  const RolePage({
    super.key,
    required this.user,
    required this.stockController,
    required this.venteController,
    required this.userController,
    required this.authHook,
  });

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  int _currentIndex = 0;

  Future<void> _ouvrirProfil() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonProfilPage(user: widget.user),
      ),
    );
  }

  Future<void> _ouvrirParametres() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParametresPage(
          user: widget.authHook.currentUser ?? widget.user,
          authHook: widget.authHook,
        ),
      ),
    );
  }

  Future<void> _modifierMotDePasse() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParametresPage(
          user: widget.authHook.currentUser ?? widget.user,
          authHook: widget.authHook,
          sectionInitiale: SectionParametres.securite,
        ),
      ),
    );
  }

  Future<void> _deconnecter() async {
    await widget.authHook.deconnecter();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Login(stockController: widget.stockController),
      ),
      (_) => false,
    );
  }

  /// Routeur interne : Évite les ternaires imbriqués complexes et lève les erreurs de parenthèses
  Widget _recupererPage() {
    switch (_currentIndex) {
      case 0:
        // Contrôle du rôle pour l'affichage du Dashboard
        if (widget.user.isAdmin) {
          return DashboardAdmin(
            stockController: widget.stockController,
            venteController: widget.venteController,
            userController: widget.userController,
            user: widget.user,
            onOuvrirProfil: _ouvrirProfil,
            onOuvrirParametres: _ouvrirParametres,
            onModifierMotDePasse: _modifierMotDePasse,
            onDeconnecter: _deconnecter,
          );
        } else {
          // Ajusté selon tes commentaires : GerantPage prend uniquement user et stockController
          return GerantPage(
            user: widget.user,
            stockController: widget.stockController,
            venteController: widget.venteController,
            onOuvrirProfil: _ouvrirProfil,
            onOuvrirParametres: _ouvrirParametres,
            onModifierMotDePasse: _modifierMotDePasse,
            onDeconnecter: _deconnecter,
            onAllerAuxVentes: () => setState(() => _currentIndex = 2), // Index des ventes
          );
        }
      case 1:
        return ProduitPage(
          stockController: widget.stockController,
          venteController: widget.venteController,
          user: widget.user,
        );
      case 2:
        return VentePage(
          venteController: widget.venteController,
          user: widget.user,
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
