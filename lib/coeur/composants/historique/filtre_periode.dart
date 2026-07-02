import 'package:flutter/material.dart';

import '../../theme/theme_quinca.dart';

enum PeriodeHistorique { aujourdHui, septJours, ceMois, tout }

class FiltrePeriode extends StatelessWidget {
  final PeriodeHistorique valeur;
  final ValueChanged<PeriodeHistorique> onChanged;

  const FiltrePeriode({
    super.key,
    required this.valeur,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _chip("Aujourd'hui", PeriodeHistorique.aujourdHui),
          _chip("7 jours", PeriodeHistorique.septJours),
          _chip("Ce mois", PeriodeHistorique.ceMois),
          _chip("Tout", PeriodeHistorique.tout),
        ],
      ),
    );
  }

  Widget _chip(String label, PeriodeHistorique periode) {
    final actif = valeur == periode;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: actif,
        onSelected: (_) => onChanged(periode),
        selectedColor: ThemeQuinca.bleuPrincipal.withValues(alpha: 0.12),
        labelStyle: TextStyle(
          color: actif ? ThemeQuinca.bleuPrincipal : ThemeQuinca.texteSecondaire,
          fontWeight: actif ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}

bool dateDansPeriode(DateTime date, PeriodeHistorique periode) {
  final now = DateTime.now();
  final debutJour = DateTime(now.year, now.month, now.day);

  switch (periode) {
    case PeriodeHistorique.aujourdHui:
      return date.isAfter(debutJour.subtract(const Duration(milliseconds: 1)));
    case PeriodeHistorique.septJours:
      return date.isAfter(now.subtract(const Duration(days: 7)));
    case PeriodeHistorique.ceMois:
      return date.year == now.year && date.month == now.month;
    case PeriodeHistorique.tout:
      return true;
  }
}
