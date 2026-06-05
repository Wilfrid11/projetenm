// lib/modules/dashboard/presentation/admin.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../produits/logique/stock_controller.dart';
import '../../ventes/logique/vente_controller.dart';

class DashboardAdmin extends StatelessWidget {
  final StockController stockController;
  final VenteController venteController;

  const DashboardAdmin({
    super.key,
    required this.stockController,
    required this.venteController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([stockController, venteController]),
      builder: (context, _) {
        // 1. CALCULS EN TEMPS RÉEL DEPUIS LE STOCKCONTROLLER
        final totalProduits = stockController.produits.length;
        
        final produitsEnRupture = stockController.produits.where((p) => p.estEnRupture).length;
        
        final produitsEnAlerte = stockController.produits.where((p) => p.estEnAlerte).length;

        // Calcul de la valeur financière totale du stock (Quantité * Prix d'achat)
        double valeurTotalStock = 0.0;
        for (var p in stockController.produits) {
          valeurTotalStock += (p.quantite * p.prixAchat);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              "Tableau de Bord Admin",
              style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF1A3B8B),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vue d'ensemble du stock",
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),

                // ZONE DES CARTES KPI DYNAMIQUES
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildKpiCard(
                      "Valeur du Stock",
                      "${valeurTotalStock.toStringAsFixed(0)} FCFA",
                      Icons.account_balance_wallet_rounded,
                      const Color(0xFF10B981),
                    ),
                    _buildKpiCard(
                      "Total Articles",
                      "$totalProduits",
                      Icons.inventory_2_rounded,
                      const Color(0xFF3B82F6),
                    ),
                    _buildKpiCard(
                      "Alertes Stock",
                      "$produitsEnAlerte",
                      Icons.warning_amber_rounded,
                      const Color(0xFFF59E0B),
                    ),
                    _buildKpiCard(
                      "Ruptures",
                      "$produitsEnRupture",
                      Icons.block_rounded,
                      const Color(0xFFEF4444),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                // Tu pourras ajouter ici la liste des dernières activités ou graphiques plus tard
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String titre, String valeur, IconData icone, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icone, color: couleur, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valeur,
                style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                titre,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}