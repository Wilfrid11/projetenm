import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../coeur/firebase/firebase_collections.dart';
import 'produit.dart';

class DepotProduitsFirebase {
  final FirebaseFirestore _firestore;

  DepotProduitsFirebase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String boutiqueId) {
    return _firestore
        .collection(FirebaseCollections.boutiques)
        .doc(boutiqueId)
        .collection(FirebaseCollections.produits);
  }

  Future<List<Produit>> chargerProduits(String boutiqueId) async {
    final snapshot = await _collection(boutiqueId)
        .where('actif', isEqualTo: true)
        .get();

    final produits =
        snapshot.docs.map((doc) => Produit.fromMap(doc.data())).toList();
    produits.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
    return produits;
  }

  Stream<List<Produit>> ecouterProduits(String boutiqueId) {
    return _collection(boutiqueId)
        .where('actif', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final produits =
          snapshot.docs.map((doc) => Produit.fromMap(doc.data())).toList();
      produits.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
      return produits;
    });
  }

  Future<Produit> ajouterProduit(Produit produit) async {
    final doc = _collection(produit.boutiqueId).doc();
    final maintenant = DateTime.now();

    final produitFinal = produit.copyWith(
      id: doc.id,
      reference:
          produit.reference.isEmpty ? _genererReference(doc.id) : produit.reference,
      actif: true,
      createdAt: maintenant,
      updatedAt: maintenant,
    );

    await doc.set(produitFinal.toMap());
    return produitFinal;
  }

  Future<List<Produit>> ajouterProduits(List<Produit> produits) async {
    if (produits.isEmpty) return [];

    final batch = _firestore.batch();
    final produitsFinalises = <Produit>[];
    final maintenant = DateTime.now();

    for (final produit in produits) {
      final doc = _collection(produit.boutiqueId).doc();
      final produitFinal = produit.copyWith(
        id: doc.id,
        reference: produit.reference.isEmpty
            ? _genererReference(doc.id)
            : produit.reference,
        actif: true,
        createdAt: maintenant,
        updatedAt: maintenant,
      );

      produitsFinalises.add(produitFinal);
      batch.set(doc, produitFinal.toMap());
    }

    // Batch Firestore : un seul envoi réseau pour enregistrer plusieurs produits.
    await batch.commit();
    return produitsFinalises;
  }

  Future<void> modifierProduit(Produit produit) async {
    await _collection(produit.boutiqueId).doc(produit.id).update(
          produit.copyWith(updatedAt: DateTime.now()).toMap(),
        );
  }

  Future<void> desactiverProduit(Produit produit) async {
    await _collection(produit.boutiqueId).doc(produit.id).update({
      'actif': false,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  String _genererReference(String documentId) {
    final suffixe = documentId.length > 8 ? documentId.substring(0, 8) : documentId;
    return 'PRD-${suffixe.toUpperCase()}';
  }
}
