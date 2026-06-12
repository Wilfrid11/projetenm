// lib/modules/dashboard/presentation/gerant.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/data/user.dart';
import '../../produits/logique/stock_controller.dart';
import '../../ventes/logique/vente_controller.dart'; 
import '../../../coeur/theme/theme_quinca.dart'; // Import du thème
import '../../produits/presentation/alertes_stock.dart'; // Import de la page d'alertes
import '../../produits/presentation/onglets/arrivage.dart'; // Import du nouvel arrivage

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
                    user: user,
                  )));
                }),
                _actionFlashBtn("Bon de sortie de stock", Icons.local_shipping_outlined, const Color(0xFFF97316), () {}),
                const SizedBox(height: 24),
                
                Text(
                  "Alertes critiques de stock",
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
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
                      return ListTile(
                        leading: Icon(p.estEnRupture ? Icons.block_rounded : Icons.warning_amber_rounded, color: couleur),
                        title: Text(p.nom, style: ThemeQuinca.corpsTexte.copyWith(fontWeight: FontWeight.bold, color: ThemeQuinca.texteFonce)),
                        subtitle: Text("Ref: ${p.reference}", style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12)),
                        trailing: Text("${p.quantite} u", style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 14, color: couleur)),
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
              if (stockController.produitsEnRupture.isNotEmpty)
                Container(
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
                    '${stockController.produitsEnRupture.length}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
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