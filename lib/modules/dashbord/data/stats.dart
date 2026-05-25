// lib/modules/dashboard/data/stats.dart

class StatsDashboard {
  final double totalVentesJounalieres;
  final double coutTotalAchat;
  final double creditsDehors;
  final int nombreRuptures;

  StatsDashboard({
    required this.totalVentesJounalieres,
    required this.coutTotalAchat,
    required this.creditsDehors,
    required this.nombreRuptures,
  });

  // TON INTENTION REPRÉSENTÉE : La formule du Bénéfice Net est calculée ici !
  double get beneficeNet => totalVentesJounalieres - coutTotalAchat;

  // Un constructeur d'usine (factory) prêt pour le JSON de ton binôme
  factory StatsDashboard.fromJson(Map<String, dynamic> json) {
    return StatsDashboard(
      totalVentesJounalieres: (json['total_ventes'] ?? 0.0).toDouble(),
      coutTotalAchat: (json['cout_achat'] ?? 0.0).toDouble(),
      creditsDehors: (json['credits_dehors'] ?? 0.0).toDouble(),
      nombreRuptures: json['nombre_ruptures'] ?? 0,
    );
  }
}