// lib/modules/dashboard/presentation/gerant.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/data/user.dart';
import '../../produits/logique/stock_controller.dart';
import '../../ventes/logique/vente_controller.dart'; 
import '../composants/alerte.dart';
import '../composants/notification_stock.dart';
import '../../produits/presentation/arrivage.dart'; // Import ajouté

class GerantPage extends StatelessWidget {
  final User user;
  final StockController stockController;
  final VenteController venteController; 
  final VoidCallback? onAllerAuxVentes; // Pour changer d'onglet

  const GerantPage({
    super.key, 
    required this.user, 
    required this.stockController,
    required this.venteController, 
    this.onAllerAuxVentes,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([stockController, venteController]),
      builder: (context, _) {
        final maintenant = DateTime.now();
        final dateAujourdhui = "${maintenant.day.toString().padLeft(2, '0')}/${maintenant.month.toString().padLeft(2, '0')}/${maintenant.year}";
        
        final nombreVentesJour = venteController.historiqueVentes
            .where((v) => v.dateVente.startsWith(dateAujourdhui))
            .length;
        
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
                  if (onAllerAuxVentes != null) onAllerAuxVentes!();
                }),
                _actionFlashBtn("Ajouter / Réceptionner produit", Icons.unarchive_rounded, const Color(0xFFEA580C), () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => ArrivagePage(
                    controller: stockController,
                    auteur: "${user.prenom} ${user.nom}",
                  )));
                }),
                _actionFlashBtn("Bon de sortie de stock", Icons.local_shipping_outlined, const Color(0xFFF97316), () {}),
                const SizedBox(height: 24),
                
                Text(
                  "Alertes critiques de stock",
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                
                ...stockController.alertesCritiques.map((produit) {
                  return AlerteCard(
                    nom: produit.nom,
                    statut: "Quantité restante : ${produit.quantite}",
                    label: produit.quantite <= 0 ? "RUPTURE" : "CRITIQUE",
                    couleur: produit.quantite <= 0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                    icone: Icons.warning_amber_rounded,
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
                  Text("${user.prenom} ${user.nom}", style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
              NotificationStock(controller: stockController),
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
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur, size: 22),
          const SizedBox(height: 8),
          Text(valeur, style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold, color: couleur)),
          const SizedBox(height: 2),
          Text(titre, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
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