class FirebaseCollections {
  FirebaseCollections._();

  static const String boutiques = 'boutiques';
  static const String users = 'users';
  static const String produits = 'produits';
  static const String ventes = 'ventes';
  static const String arrivages = 'arrivages';
  static const String fournisseurs = 'fournisseurs';

  static String boutiqueDocument(String boutiqueId) => '$boutiques/$boutiqueId';

  static String collectionBoutique(String boutiqueId, String collection) {
    return '${boutiqueDocument(boutiqueId)}/$collection';
  }

  static String produitsBoutique(String boutiqueId) =>
      collectionBoutique(boutiqueId, produits);

  static String ventesBoutique(String boutiqueId) =>
      collectionBoutique(boutiqueId, ventes);

  static String arrivagesBoutique(String boutiqueId) =>
      collectionBoutique(boutiqueId, arrivages);

  static String fournisseursBoutique(String boutiqueId) =>
      collectionBoutique(boutiqueId, fournisseurs);

  static String usersBoutique(String boutiqueId) =>
      collectionBoutique(boutiqueId, users);
}
