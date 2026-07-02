// lib/modules/dashboard/presentation/admin.dart

import 'package:flutter/material.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../produits/logique/stock_controller.dart';
import '../../ventes/logique/vente_controller.dart';
import '../../produits/presentation/alertes_stock.dart';
import '../../auth/logique/user_controller.dart';
import '../../auth/presentation/gestion_utilisateurs.dart';
import '../../auth/data/user.dart';
import '../../fournisseurs/presentation/fournisseurs_page.dart';

class DashboardAdmin extends StatelessWidget {
  final StockController stockController;
  final VenteController venteController;
  final UserController userController;
  final User user;

  const DashboardAdmin({
    super.key,
    required this.stockController,
    required this.venteController,
    required this.userController,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([stockController, venteController]),
      builder: (context, _) {
        // 1. CALCULS EN TEMPS RÉEL DEPUIS LE STOCKCONTROLLER
        final nbrRuptures = stockController.produitsEnRupture.length;
        final nbrAlertes = stockController.produitsEnAlerte.length;
        final caJour = venteController.chiffreAffaireJour;
        final benefice = venteController.beneficeJour;

        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          appBar: AppBar(
            title: Text(
              "Tableau de Bord Admin",
              style: ThemeQuinca.titrePrincipal.copyWith(color: Colors.white),
            ),
            backgroundColor: ThemeQuinca.bleuPrincipal,
            elevation: 0,
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlertesStockPage(controller: stockController),
                        ),
                      );
                    },
                  ),
                  if (nbrRuptures > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: ThemeQuinca.rupture,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$nbrRuptures',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vue d'ensemble du jour",
                  style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),

                // ZONE DES CARTES KPI DYNAMIQUES
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 110,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildKpiCard(
                      "Ventes (CA)",
                      "${caJour.toInt()} FCFA",
                      Icons.trending_up_rounded,
                      ThemeQuinca.bleuPrincipal,
                    ),
                    _buildKpiCard(
                      "Bénéfice Jour",
                      "${benefice.toInt()} FCFA",
                      Icons.auto_graph_rounded,
                      ThemeQuinca.succes,
                    ),
                    _buildKpiCard(
                      "Alertes Stock",
                      "$nbrAlertes",
                      Icons.warning_amber_rounded,
                      ThemeQuinca.alerte,
                    ),
                    _buildKpiCard(
                      "Ruptures",
                      "$nbrRuptures",
                      Icons.block_rounded,
                      ThemeQuinca.rupture,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                Text("Actions rapides", style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 18)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionCard(
                      context, 
                      "Utilisateurs", 
                      Icons.people_alt_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => GestionUtilisateursPage(
                          userController: userController, 
                          admin: user)
                      )),
                    ),
                    _buildActionCard(
                      context,
                      "Fournisseurs",
                      Icons.local_shipping_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FournisseursPage(user: user),
                        ),
                      ),
                    ),
                    _buildActionCard(context, "Inventaire", Icons.inventory_outlined),
                  ],
                ),

                const SizedBox(height: 32),
                Text("Alertes & Ruptures", style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                
                if (stockController.alertesCritiques.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Aucun produit en alerte pour le moment.", style: ThemeQuinca.corpsTexte),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stockController.alertesCritiques.length,
                    itemBuilder: (context, index) {
                      final p = stockController.alertesCritiques[index];
                      final couleur = p.estEnRupture ? ThemeQuinca.rupture : ThemeQuinca.alerte;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeQuinca.bordure),
                        ),
                        child: ListTile(
                          leading: Icon(p.estEnRupture ? Icons.block_rounded : Icons.warning_amber_rounded, color: couleur),
                          title: Text(p.nom, style: ThemeQuinca.corpsTexte.copyWith(fontWeight: FontWeight.bold, color: ThemeQuinca.texteFonce)),
                          subtitle: Text("Ref: ${p.reference}", style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12)),
                          trailing: Text("${p.quantite} u", style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 14, color: couleur)),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context, String titre, IconData icone, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$titre : En cours de développement"))),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeQuinca.bordure),
          ),
          child: Column(
            children: [
              Icon(icone, color: ThemeQuinca.bleuPrincipal),
              const SizedBox(height: 8),
              Text(titre, style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String titre, String valeur, IconData icone, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icone, color: couleur, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valeur,
                style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                titre,
                style: ThemeQuinca.corpsTexte.copyWith(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
