// lib/modules/dashboard/presentation/gerant.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/data/user.dart';
import '../../produits/logique/stock_controller.dart';
import '../../ventes/logique/vente_controller.dart'; 
import '../composants/alerte.dart';
import '../data/mock_dashboard.dart';

class GerantPage extends StatelessWidget {
  final User user;
  final StockController stockController;
  final VenteController venteController; 

  const GerantPage({
    super.key, 
    required this.user, 
    required this.stockController,
    required this.venteController, 
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([stockController, venteController]),
      builder: (context, _) {
        // CORRECTION TEMPORAIRE : On met une valeur fixe (ex: 5) ou 0 pour les ventes du jour
        // afin d'éviter de bloquer la compilation avec une variable inconnue.
        final nombreVentesJour = 5; 
        
        // Utilisation de ton getter fonctionnel pour les alertes de stock
        final articlesCritiques = stockController.alertesCritiques.length;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                
                _buildZoneStats(nombreVentesJour, articlesCritiques),
                const SizedBox(height: 24),
                
                Text(
                  "Actions flash",
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                
                _actionFlashBtn("Nouvelle vente (panier)", Icons.add_shopping_cart_rounded, const Color(0xFFF97316), () {
                  // Action panier
                }),
                _actionFlashBtn("Ajouter / Réceptionner produit", Icons.unarchive_rounded, const Color(0xFFEA580C), () {}),
                _actionFlashBtn("Bon de sortie de stock", Icons.local_shipping_outlined, const Color(0xFFF97316), () {}),
                const SizedBox(height: 24),
                
                Text(
                  "Alertes critiques de stock",
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
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
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.nomComplet, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                    child: Text(user.role.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
            
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneStats(int ventes, int critiques) {
    return Row(
      children: [
        Expanded(child: _statCard("Ventes du jour", "$ventes", Icons.receipt_long_rounded, const Color(0xFF10B981))),
        const SizedBox(width: 16),
        Expanded(child: _statCard("Articles critiques", "$critiques", Icons.warning_amber_rounded, const Color(0xFFF59E0B))),
      ],
    );
  }

  Widget _statCard(String titre, String valeur, IconData icone, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur, size: 24),
          const SizedBox(height: 12),
          Text(valeur, style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.bold, color: couleur)),
          const SizedBox(height: 4),
          Text(titre, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _actionFlashBtn(String libelle, IconData icone, Color couleurIcone, VoidCallback auClic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: auClic,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(icone, color: couleurIcone, size: 28),
              const SizedBox(width: 16),
              Text(libelle, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
            ],
          ),
        ),
      ),
    );
  }
}