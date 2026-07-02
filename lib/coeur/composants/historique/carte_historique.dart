import 'package:flutter/material.dart';

import '../../theme/theme_quinca.dart';

class CarteHistorique extends StatelessWidget {
  final String titre;
  final String sousTitre;
  final String dateLabel;
  final String resume;
  final IconData icone;
  final VoidCallback onTap;
  final VoidCallback onMasquer;

  const CarteHistorique({
    super.key,
    required this.titre,
    required this.sousTitre,
    required this.dateLabel,
    required this.resume,
    required this.icone,
    required this.onTap,
    required this.onMasquer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeQuinca.bordure),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: ThemeQuinca.alerte.withValues(alpha: 0.12),
          child: Icon(icone, color: ThemeQuinca.alerte),
        ),
        title: Text(
          titre,
          style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(dateLabel, style: ThemeQuinca.corpsTexte.copyWith(fontSize: 11)),
            Text(sousTitre, style: ThemeQuinca.corpsTexte.copyWith(fontSize: 11)),
            const SizedBox(height: 5),
            Text(
              resume,
              style: ThemeQuinca.corpsTexte.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ThemeQuinca.texteFonce,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: ThemeQuinca.rupture),
          onPressed: onMasquer,
          tooltip: "Masquer",
        ),
      ),
    );
  }
}
