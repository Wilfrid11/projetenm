class Fournisseur {
  final String id;
  final String boutiqueId;
  final String nom;
  final String telephone;
  final String adresse;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Fournisseur({
    required this.id,
    required this.boutiqueId,
    required this.nom,
    this.telephone = '',
    this.adresse = '',
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boutiqueId': boutiqueId,
      'nom': nom,
      'telephone': telephone,
      'adresse': adresse,
      'actif': actif,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Fournisseur.fromMap(Map<String, dynamic> map) {
    return Fournisseur(
      id: map['id'] as String? ?? '',
      boutiqueId: map['boutiqueId'] as String? ?? '',
      nom: map['nom'] as String? ?? '',
      telephone: map['telephone'] as String? ?? '',
      adresse: map['adresse'] as String? ?? '',
      actif: map['actif'] as bool? ?? true,
      createdAt: _dateDepuisMap(map['createdAt']),
      updatedAt: _dateDepuisMap(map['updatedAt']),
    );
  }

  Fournisseur copyWith({
    String? id,
    String? boutiqueId,
    String? nom,
    String? telephone,
    String? adresse,
    bool? actif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Fournisseur(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      actif: actif ?? this.actif,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _dateDepuisMap(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
