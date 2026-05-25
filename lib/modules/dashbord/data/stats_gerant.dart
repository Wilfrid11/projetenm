// lib/modules/dashboard/data/stats_gerant.dart

class StatsGerant {
  final int nombreVentesJour;
  final int articlesCritiques;

  StatsGerant({
    required this.nombreVentesJour,
    required this.articlesCritiques,
  });

  // Prêt à accueillir le JSON du backend pour Amos
  factory StatsGerant.fromJson(Map<String, dynamic> json) {
    return StatsGerant(
      nombreVentesJour: json['nombre_ventes_jour'] ?? 0,
      articlesCritiques: json['articles_critiques'] ?? 0,
    );
  }
}