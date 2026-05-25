// lib/modules/produit/presentation/onglets/historique.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logique/stock_controller.dart';

class HistoriqueScreen extends StatelessWidget {
  final StockController controller;

  const HistoriqueScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final fluxHistorique = controller.historique;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(
          "Journal des Approvisionnements",
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
      ),
      body: fluxHistorique.isEmpty
          ? const Center(child: Text("Aucun arrivage enregistré pour le moment."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: fluxHistorique.length,
              itemBuilder: (context, index) {
                final item = fluxHistorique[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['produit'], style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Reçu par : ${item['auteur']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text("Le : ${item['date']}", style: const TextStyle(fontSize: 11, color: Colors.black45)),
                        ],
                      ),
                      Text(
                        "+ ${item['quantite']} u",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}