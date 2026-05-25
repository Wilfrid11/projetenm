// lib/modules/dashboard/presentation/admin.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../composants/alerte.dart';
import '../logique/dashboard_hook.dart';
import '../data/mock_dashboard.dart';
import '../../auth/data/user.dart'; 
// ÉTAPE A : On importe l'écran des produits qu'on a créé ensemble
import '../../produits/presentation/produit.dart';
import '../../produits/logique/stock_controller.dart'; // On importe aussi le moteur logique du stock pour le passer à l'écran des produits
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  final HookDashboard _dashboardHook = HookDashboard();
final StockController _stockController = StockController();
  @override
  Widget build(BuildContext context) {
    final stats = _dashboardHook.statsAdmin;
    final User user = _dashboardHook.utilisateurConnecte; 

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      
      // ÉTAPE B : On choisit quel écran afficher en fonction de l'onglet sélectionné
      body: _currentIndex == 0
    ? _buildVueAccueilAdmin(user, stats) // Si index 0, on affiche l'accueil financier
    : _currentIndex == 1
        ? ProduitsScreen(
            utilisateurConnecte: user,
            stockController: _stockController, // <-- MODIFICATION ICI : On passe le moteur logique
          ) 
        : Center(child: Text("Écran en cours de développement (Index: $_currentIndex)")), // Pour les index 2 et 3
        
bottomNavigationBar: _buildBottomBar(),
);
  }

  // ÉTAPE C : On isole ton ancienne vue d'accueil de l'admin ici pour qu'elle ne bloque plus le changement d'écran
  Widget _buildVueAccueilAdmin(User user, dynamic stats) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user),
            const SizedBox(height: 24),

            // Zone financière avec la carte "À faire"
            _buildZoneFinanciere(stats),
            const SizedBox(height: 24),

            // Zone des boutons d'actions prêts à être développés
            _buildActionsRapides(),
            const SizedBox(height: 28),

            Text(
              "Alertes critiques de stock",
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            ...mockAlertesStock.map((alerte) {
              return AlerteCard(
                nom: alerte['nom'],
                statut: alerte['statut'],
                label: alerte['label'],
                couleur: alerte['couleur'],
                icone: alerte['icone'],
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF1A3B8B),
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nomComplet, 
                  style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                Text(
                  user.role.toUpperCase(), 
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Text(
              user.nomBoutique, 
              style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A3B8B)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.notifications_none_rounded, size: 24, color: Color(0xFF0F172A)),
          ],
        ),
      ],
    );
  }

  Widget _buildZoneFinanciere(dynamic stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _miniCard("Chiffre d'Affaires", "${stats.totalVentesJounalieres.toInt()} F", Icons.trending_up, const Color(0xFF10B981)),
        _miniCard("Bénéfice Net", "${stats.beneficeNet.toInt()} F", Icons.account_balance_wallet, const Color(0xFF1A3B8B)),
        _miniCard("Crédits (À faire)", "${stats.creditsDehors.toInt()} F", Icons.assignment_late, const Color(0xFFEF4444)),
        _miniCard("Ruptures", "${stats.nombreRuptures} articles", Icons.block, const Color(0xFFFD7E14)),
      ],
    );
  }

  Widget _miniCard(String titre, String valeur, IconData icone, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(titre, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)), overflow: TextOverflow.ellipsis)),
              Icon(icone, color: couleur, size: 18),
            ],
          ),
          Text(valeur, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildActionsRapides() {
    return Row(
      children: [
        _actionBtn("Bilans", Icons.bar_chart_rounded, () {
          print("Clic sur Bilans : À développer après");
        }),
        const SizedBox(width: 10),
        _actionBtn("Utilisateurs", Icons.group_outlined, () {
          print("Clic sur Utilisateurs : À développer après");
        }),
        const SizedBox(width: 10),
        _actionBtn("Inventaire", Icons.factory_outlined, () {
          print("Clic sur Inventaire : À développer après");
        }),
      ],
    );
  }

  Widget _actionBtn(String libelle, IconData icone, VoidCallback auClic) {
    return Expanded(
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: InkWell(
          onTap: auClic, 
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: const Color(0xFF1A3B8B), size: 20),
              const SizedBox(height: 6),
              Text(libelle, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1A3B8B),
      unselectedItemColor: const Color(0xFF64748B),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Accueil"),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Produits"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: "Ventes"),
        BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "Historique"),
      ],
    );
  }
}