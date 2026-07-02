import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../coeur/firebase/firebase_collections.dart';
import 'fournisseur.dart';

class DepotFournisseursFirebase {
  final FirebaseFirestore _firestore;

  DepotFournisseursFirebase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String boutiqueId) {
    return _firestore
        .collection(FirebaseCollections.boutiques)
        .doc(boutiqueId)
        .collection(FirebaseCollections.fournisseurs);
  }

  Future<List<Fournisseur>> chargerFournisseurs(String boutiqueId) async {
    final snapshot =
        await _collection(boutiqueId).where('actif', isEqualTo: true).get();
    final fournisseurs =
        snapshot.docs.map((doc) => Fournisseur.fromMap(doc.data())).toList();
    fournisseurs.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
    return fournisseurs;
  }

  Future<Fournisseur> ajouterFournisseur(Fournisseur fournisseur) async {
    final doc = _collection(fournisseur.boutiqueId).doc();
    final maintenant = DateTime.now();
    final fournisseurFinal = fournisseur.copyWith(
      id: doc.id,
      actif: true,
      createdAt: maintenant,
      updatedAt: maintenant,
    );

    await doc.set(fournisseurFinal.toMap());
    return fournisseurFinal;
  }

  Future<void> modifierFournisseur(Fournisseur fournisseur) async {
    await _collection(fournisseur.boutiqueId).doc(fournisseur.id).update(
          fournisseur.copyWith(updatedAt: DateTime.now()).toMap(),
        );
  }

  Future<void> desactiverFournisseur(Fournisseur fournisseur) async {
    await _collection(fournisseur.boutiqueId).doc(fournisseur.id).update({
      'actif': false,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
