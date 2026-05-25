// lib/modules/dashboard/composants/alerte.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlerteCard extends StatelessWidget {
  final String nom;
  final String statut;
  final String label;
  final Color couleur;
  final IconData icone;

  const AlerteCard({
    super.key,
    required this.nom,
    required this.statut,
    required this.label,
    required this.couleur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Languette latérale colorée (gauche)
          Container(
            width: 5,
            decoration: BoxDecoration(
              color: couleur,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Cercle avec icône d'alerte
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: couleur.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(icone, color: couleur, size: 18),
          ),
          const SizedBox(width: 12),
          // Textes informatifs du produit
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  statut,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          // Tag textuel à droite (RUPTURE ou CRITIQUE)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: couleur, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}