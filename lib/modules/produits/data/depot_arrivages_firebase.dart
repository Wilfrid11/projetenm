import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../coeur/firebase/firebase_collections.dart';
import '../../historique/data/historique_models.dart';

class DepotArrivagesFirebase {
  final FirebaseFirestore _firestore;

  DepotArrivagesFirebase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _arrivages(String boutiqueId) {
    return _firestore
        .collection(FirebaseCollections.boutiques)
        .doc(boutiqueId)
        .collection(FirebaseCollections.arrivages);
  }

  CollectionReference<Map<String, dynamic>> _produits(String boutiqueId) {
    return _firestore
        .collection(FirebaseCollections.boutiques)
        .doc(boutiqueId)
        .collection(FirebaseCollections.produits);
  }

  Future<List<EntreeFournisseur>> chargerArrivages(String boutiqueId) async {
    final snapshot = await _arrivages(boutiqueId)
        .where('visible', isEqualTo: true)
        .get();

    final arrivages =
        snapshot.docs.map((doc) => EntreeFournisseur.fromMap(doc.data())).toList();
    arrivages.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });
    return arrivages;
  }

  Stream<List<EntreeFournisseur>> ecouterArrivages(String boutiqueId) {
    return _arrivages(boutiqueId)
        .where('visible', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final arrivages =
          snapshot.docs.map((doc) => EntreeFournisseur.fromMap(doc.data())).toList();
      arrivages.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
      return arrivages;
    });
  }

  Future<EntreeFournisseur> validerArrivage(
    EntreeFournisseur arrivage,
  ) async {
    final doc = _arrivages(arrivage.boutiqueId).doc();
    final maintenant = DateTime.now();
    final entreeFinale = EntreeFournisseur(
      id: doc.id,
      boutiqueId: arrivage.boutiqueId,
      fournisseurId: arrivage.fournisseurId,
      fournisseur: arrivage.fournisseur,
      dateArrivage: arrivage.dateArrivage,
      auteurId: arrivage.auteurId,
      auteur: arrivage.auteur,
      lignes: arrivage.lignes,
      createdAt: maintenant,
      visible: true,
    );

    final batch = _firestore.batch();

    // Une validation d'arrivage doit garder deux choses synchronisees :
    // l'historique de livraison et l'augmentation du stock de chaque produit.
    batch.set(doc, entreeFinale.toMap());
    for (final ligne in entreeFinale.lignes) {
      if (ligne.produitId.isEmpty) continue;
      final produitRef = _produits(entreeFinale.boutiqueId).doc(ligne.produitId);
      batch.update(produitRef, {
        'quantite': FieldValue.increment(ligne.quantiteRecue),
        'updatedAt': maintenant.toIso8601String(),
      });
    }

    await batch.commit();
    return entreeFinale;
  }

  Future<void> masquerArrivage(EntreeFournisseur entree) async {
    await _arrivages(entree.boutiqueId).doc(entree.id).update({
      'visible': false,
    });
  }
}
