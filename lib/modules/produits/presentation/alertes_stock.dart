import 'package:flutter/material.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../logique/stock_controller.dart';
import '../data/produit.dart';

class AlertesStockPage extends StatelessWidget {
  final StockController controller;

  const AlertesStockPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        title: Text(
          "Alertes & Ruptures",
          style: ThemeQuinca.titrePrincipal.copyWith(color: Colors.white),
        ),
        backgroundColor: ThemeQuinca.bleuPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final ruptures = controller.produitsEnRupture;
          final alertes = controller.produitsEnAlerte;

          if (ruptures.isEmpty && alertes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 80,
                    color: ThemeQuinca.succes.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tout est en ordre !",
                    style: ThemeQuinca.titrePrincipal,
                  ),
                  Text(
                    "Aucun produit en rupture ou en alerte.",
                    style: ThemeQuinca.corpsTexte,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (ruptures.isNotEmpty) ...[
                _buildSectionHeader("Ruptures critiques", ThemeQuinca.rupture),
                const SizedBox(height: 12),
                ...ruptures.map((p) => _buildAlertCard(p, ThemeQuinca.rupture)),
                const SizedBox(height: 24),
              ],
              if (alertes.isNotEmpty) ...[
                _buildSectionHeader("Stocks faibles", ThemeQuinca.alerte),
                const SizedBox(height: 12),
                ...alertes.map((p) => _buildAlertCard(p, ThemeQuinca.alerte)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String titre, Color couleur) {
    return Text(
      titre.toUpperCase(),
      style: ThemeQuinca.corpsTexte.copyWith(
        fontWeight: FontWeight.bold,
        color: couleur,
        letterSpacing: 1.2,
        fontSize: 12,
      ),
    );
  }

  Widget _buildAlertCard(Produit p, Color couleur) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          Icon(
            p.estEnRupture ? Icons.block_rounded : Icons.warning_amber_rounded,
            color: couleur,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nom, style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16)),
                Text("Réf: ${p.reference}", style: ThemeQuinca.corpsTexte),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${p.quantite} u",
                style: ThemeQuinca.titrePrincipal.copyWith(color: couleur),
              ),
              Text(
                "Seuil: ${p.seuilAlerte}",
                style: ThemeQuinca.corpsTexte.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}