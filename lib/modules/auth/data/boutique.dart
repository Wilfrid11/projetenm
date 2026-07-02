class Boutique {
  final String id;
  final String nom;
  final String adresse;
  final String ville;
  final String telephone;
  final String ownerId;
  final DateTime createdAt;

  const Boutique({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.ville,
    required this.telephone,
    required this.ownerId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'ville': ville,
      'telephone': telephone,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
