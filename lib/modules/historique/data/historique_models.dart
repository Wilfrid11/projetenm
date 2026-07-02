// lib/modules/historique/data/historique_models.dart

// =======================================================
// 1. Modeles pour l'historique des entrees / arrivages
// =======================================================

class LigneEntree {
  final String produitId;
  final String nomProduit;
  final String categorie;
  final String uniteVente;
  final int quantiteRecue;

  LigneEntree({
    this.produitId = '',
    required this.nomProduit,
    required this.categorie,
    this.uniteVente = 'piece',
    required this.quantiteRecue,
  });

  Map<String, dynamic> toMap() {
    return {
      'produitId': produitId,
      'nomProduit': nomProduit,
      'categorie': categorie,
      'uniteVente': uniteVente,
      'quantiteRecue': quantiteRecue,
    };
  }

  factory LigneEntree.fromMap(Map<String, dynamic> map) {
    return LigneEntree(
      produitId: map['produitId'] as String? ?? '',
      nomProduit: map['nomProduit'] as String? ?? '',
      categorie: map['categorie'] as String? ?? '',
      uniteVente: map['uniteVente'] as String? ?? 'piece',
      quantiteRecue: (map['quantiteRecue'] as num?)?.toInt() ?? 0,
    );
  }
}

class EntreeFournisseur {
  final String id;
  final String boutiqueId;
  final String fournisseurId;
  final String fournisseur;
  final String dateArrivage;
  final String auteurId;
  final String auteur;
  final List<LigneEntree> lignes;
  final DateTime? createdAt;
  final bool visible;

  EntreeFournisseur({
    required this.id,
    required this.boutiqueId,
    this.fournisseurId = '',
    required this.fournisseur,
    required this.dateArrivage,
    this.auteurId = '',
    required this.auteur,
    required this.lignes,
    this.createdAt,
    this.visible = true,
  });

  int get totalQuantites =>
      lignes.fold(0, (total, ligne) => total + ligne.quantiteRecue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boutiqueId': boutiqueId,
      'fournisseurId': fournisseurId,
      'fournisseur': fournisseur,
      'dateArrivage': dateArrivage,
      'auteurId': auteurId,
      'auteur': auteur,
      'lignes': lignes.map((ligne) => ligne.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'visible': visible,
    };
  }

  factory EntreeFournisseur.fromMap(Map<String, dynamic> map) {
    final lignesBrutes = map['lignes'];

    return EntreeFournisseur(
      id: map['id'] as String? ?? '',
      boutiqueId: map['boutiqueId'] as String? ?? '',
      fournisseurId: map['fournisseurId'] as String? ?? '',
      fournisseur: map['fournisseur'] as String? ?? '',
      dateArrivage: map['dateArrivage'] as String? ?? '',
      auteurId: map['auteurId'] as String? ?? '',
      auteur: map['auteur'] as String? ?? '',
      lignes: lignesBrutes is List
          ? lignesBrutes
              .whereType<Map<String, dynamic>>()
              .map(LigneEntree.fromMap)
              .toList()
          : const [],
      createdAt: _dateDepuisMap(map['createdAt']),
      visible: map['visible'] as bool? ?? true,
    );
  }
}

// =======================================================
// 2. Modeles pour l'historique des ventes
// =======================================================

class LigneVente {
  final String nomProduit;
  final String categorie;
  final int quantiteVendue;
  final double prixUnitaire;
  final double prixAchat;

  LigneVente({
    required this.nomProduit,
    required this.categorie,
    required this.quantiteVendue,
    required this.prixUnitaire,
    required this.prixAchat,
  });

  Map<String, dynamic> toMap() {
    return {
      'nomProduit': nomProduit,
      'categorie': categorie,
      'quantiteVendue': quantiteVendue,
      'prixUnitaire': prixUnitaire,
      'prixAchat': prixAchat,
    };
  }

  factory LigneVente.fromMap(Map<String, dynamic> map) {
    return LigneVente(
      nomProduit: map['nomProduit'] as String? ?? '',
      categorie: map['categorie'] as String? ?? '',
      quantiteVendue: (map['quantiteVendue'] as num?)?.toInt() ?? 0,
      prixUnitaire: (map['prixUnitaire'] as num?)?.toDouble() ?? 0,
      prixAchat: (map['prixAchat'] as num?)?.toDouble() ?? 0,
    );
  }
}

class VenteRealisee {
  final String numRecu;
  final String boutiqueId;
  final String dateVente;
  final String moyenPaiement;
  final List<LigneVente> panier;

  VenteRealisee({
    required this.numRecu,
    required this.boutiqueId,
    required this.dateVente,
    required this.moyenPaiement,
    required this.panier,
  });

  int get totalArticles =>
      panier.fold(0, (sum, item) => sum + item.quantiteVendue);

  double get montantTotal => panier.fold(
        0.0,
        (sum, item) => sum + (item.prixUnitaire * item.quantiteVendue),
      );

  Map<String, dynamic> toMap() {
    return {
      'numRecu': numRecu,
      'boutiqueId': boutiqueId,
      'dateVente': dateVente,
      'moyenPaiement': moyenPaiement,
      'panier': panier.map((ligne) => ligne.toMap()).toList(),
    };
  }

  factory VenteRealisee.fromMap(Map<String, dynamic> map) {
    final panierBrut = map['panier'];

    return VenteRealisee(
      numRecu: map['numRecu'] as String? ?? '',
      boutiqueId: map['boutiqueId'] as String? ?? '',
      dateVente: map['dateVente'] as String? ?? '',
      moyenPaiement: map['moyenPaiement'] as String? ?? '',
      panier: panierBrut is List
          ? panierBrut
              .whereType<Map<String, dynamic>>()
              .map(LigneVente.fromMap)
              .toList()
          : const [],
    );
  }
}

DateTime? _dateDepuisMap(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
