import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../coeur/firebase/firebase_collections.dart';
import '../../historique/data/historique_models.dart';

class DepotVentesFirebase {
  final FirebaseFirestore _firestore;

  DepotVentesFirebase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ventes(String boutiqueId) {
    return _firestore
        .collection(FirebaseCollections.boutiques)
        .doc(boutiqueId)
        .collection(FirebaseCollections.ventes);
  }

  CollectionReference<Map<String, dynamic>> _produits(String boutiqueId) {
    return _firestore
        .collection(FirebaseCollections.boutiques)
        .doc(boutiqueId)
        .collection(FirebaseCollections.produits);
  }

  Stream<List<VenteRealisee>> ecouterVentes(String boutiqueId) {
    return _ventes(boutiqueId)
        .where('visible', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final ventes =
          snapshot.docs.map((doc) => VenteRealisee.fromMap(doc.data())).toList();
      ventes.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
      return ventes;
    });
  }

  Future<VenteRealisee> validerVente(VenteRealisee vente) async {
    final doc = _ventes(vente.boutiqueId).doc();
    final maintenant = DateTime.now();
    final venteFinale = VenteRealisee(
      id: doc.id,
      numRecu: vente.numRecu,
      boutiqueId: vente.boutiqueId,
      dateVente: vente.dateVente,
      moyenPaiement: vente.moyenPaiement,
      panier: vente.panier,
      vendeurId: vente.vendeurId,
      vendeurNom: vente.vendeurNom,
      createdAt: maintenant,
      visible: true,
      montantRecu: vente.montantRecu,
      monnaieRendue: vente.monnaieRendue,
      notePaiement: vente.notePaiement,
    );

    await _firestore.runTransaction((transaction) async {
      final produitRefs = venteFinale.panier
          .map((ligne) => _produits(venteFinale.boutiqueId).doc(ligne.produitId))
          .toList();
      final snapshots = <DocumentSnapshot<Map<String, dynamic>>>[];

      for (final ref in produitRefs) {
        snapshots.add(await transaction.get(ref));
      }

      // La transaction verifie le stock reel au moment exact de la vente.
      for (var i = 0; i < venteFinale.panier.length; i++) {
        final ligne = venteFinale.panier[i];
        final snapshot = snapshots[i];
        final data = snapshot.data();
        final stockActuel = (data?['quantite'] as num?)?.toInt() ?? 0;

        if (!snapshot.exists || stockActuel < ligne.quantiteVendue) {
          throw StateError('Stock insuffisant pour ${ligne.nomProduit}');
        }
      }

      transaction.set(doc, venteFinale.toMap());
      for (var i = 0; i < venteFinale.panier.length; i++) {
        final ligne = venteFinale.panier[i];
        transaction.update(produitRefs[i], {
          'quantite': FieldValue.increment(-ligne.quantiteVendue),
          'updatedAt': maintenant.toIso8601String(),
        });
      }
    });

    return venteFinale;
  }

  Future<void> masquerVente(VenteRealisee vente) async {
    await _ventes(vente.boutiqueId).doc(vente.id).update({'visible': false});
  }
}
