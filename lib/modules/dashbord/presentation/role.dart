// lib/modules/dashboard/presentation/role.dart

import 'package:flutter/material.dart';
import '../../auth/data/user.dart';
import '../../produits/logique/stock_controller.dart'; // Ajusté selon l'arborescence standard
import '../../ventes/logique/vente_controller.dart';
import '../../produits/presentation/produit.dart';
import '../../ventes/presentation/vente.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _currentIndex == 0
          ? (widget.user.role == 'admin'
                ? DashboardAdmin(
                    stockController: widget.stockController,
                    venteController: widget.venteController,
                  )
                : GerantPage(
                    user: widget.user,
                    stockController: widget.stockController,
                    venteController: widget.venteController,
                  )) // Corrigé : GerantPage prend uniquement user et stockController
          : _currentIndex == 1
          ? ProduitPage(
              stockController: widget.stockController,
              user: widget.user, // 👈 Si la variable est dans ton State
            ) // Corrigé : ProduitPage prend uniquement son stockController
          : _currentIndex == 2
          ? VentePage(venteController: widget.venteController)
          : Center(
              child: Text(
                "Historique en cours de développement (Index: $_currentIndex)",
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: widget.user.role == 'admin'
            ? const Color(0xFF1A3B8B)
            : const Color(0xFF1E3A8A),
        unselectedItemColor: const Color(0xFF64748B),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: "Produits",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Ventes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: "Historique",
          ),
        ],
      ),
    );
  }
}
