// lib/modules/produit/data/produit.dart

class Produit {
  final String id;
  final String boutiqueId;
  final String reference;
  final String nom;
  final String categorie;
  final String uniteVente;
  int quantite;
  final double prixAchat;
  final double prixVente;
  final int seuilAlerte;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Produit({
    required this.id,
    required this.boutiqueId,
    required this.reference,
    required this.nom,
    required this.categorie,
    this.uniteVente = 'pièce',
    required this.quantite,
    required this.prixAchat,
    required this.prixVente,
    required this.seuilAlerte,
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  // Déjà ajouté au tour précédent
  bool get estEnRupture => quantite <= 0;

  // AJOUT : Permet à l'admin de compter les stocks faibles (en alerte mais pas encore épuisés)
  bool get estEnAlerte => quantite > 0 && quantite <= seuilAlerte;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boutiqueId': boutiqueId,
      'reference': reference,
      'nom': nom,
      'categorie': categorie,
      'uniteVente': uniteVente,
      'quantite': quantite,
      'prixAchat': prixAchat,
      'prixVente': prixVente,
      'seuilAlerte': seuilAlerte,
      'actif': actif,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id'] as String? ?? '',
      boutiqueId: map['boutiqueId'] as String? ?? '',
      reference: map['reference'] as String? ?? '',
      nom: map['nom'] as String? ?? '',
      categorie: map['categorie'] as String? ?? 'Général',
      uniteVente: map['uniteVente'] as String? ?? 'pièce',
      quantite: (map['quantite'] as num?)?.toInt() ?? 0,
      prixAchat: (map['prixAchat'] as num?)?.toDouble() ?? 0,
      prixVente: (map['prixVente'] as num?)?.toDouble() ?? 0,
      seuilAlerte: (map['seuilAlerte'] as num?)?.toInt() ?? 5,
      actif: map['actif'] as bool? ?? true,
      createdAt: _dateDepuisMap(map['createdAt']),
      updatedAt: _dateDepuisMap(map['updatedAt']),
    );
  }

  Produit copyWith({
    String? id,
    String? boutiqueId,
    String? reference,
    String? nom,
    String? categorie,
    String? uniteVente,
    int? quantite,
    double? prixAchat,
    double? prixVente,
    int? seuilAlerte,
    bool? actif,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Produit(
      id: id ?? this.id,
      boutiqueId: boutiqueId ?? this.boutiqueId,
      reference: reference ?? this.reference,
      nom: nom ?? this.nom,
      categorie: categorie ?? this.categorie,
      uniteVente: uniteVente ?? this.uniteVente,
      quantite: quantite ?? this.quantite,
      prixAchat: prixAchat ?? this.prixAchat,
      prixVente: prixVente ?? this.prixVente,
      seuilAlerte: seuilAlerte ?? this.seuilAlerte,
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
