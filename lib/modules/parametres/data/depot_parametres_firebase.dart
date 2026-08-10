import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../coeur/firebase/firebase_collections.dart';
import '../../auth/data/user.dart';
import '../../auth/logique/telephone_utils.dart';

class DepotParametresFirebase {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  DepotParametresFirebase({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  Future<User> modifierInfosPersonnelles({
    required User user,
    required String nom,
    required String prenom,
  }) async {
    final userMisAJour = user.copyWith(nom: nom, prenom: prenom);

    await _firestore
        .collection(FirebaseCollections.users)
        .doc(user.id)
        .update({
      'nom': nom,
      'prenom': prenom,
    });

    return userMisAJour;
  }

  Future<User> modifierInfosBoutique({
    required User user,
    required String nomBoutique,
    required String adresse,
    required String ville,
    required String telephoneBoutique,
  }) async {
    final userMisAJour = user.copyWith(
      nomBoutique: nomBoutique,
      adresse: adresse,
      ville: ville,
      telephoneBoutique: telephoneBoutique,
    );

    final batch = _firestore.batch();
    final boutiqueRef = _firestore
        .collection(FirebaseCollections.boutiques)
        .doc(user.boutiqueId);

    batch.update(boutiqueRef, {
      'nom': nomBoutique,
      'adresse': adresse,
      'ville': ville,
      'telephone': telephoneBoutique,
    });

    final utilisateurs = await _firestore
        .collection(FirebaseCollections.users)
        .where('boutiqueId', isEqualTo: user.boutiqueId)
        .get();

    // Les infos boutique sont dupliquees sur les utilisateurs pour garder
    // les ecrans actuels simples et coherents apres connexion.
    for (final doc in utilisateurs.docs) {
      batch.update(doc.reference, {
        'nomBoutique': nomBoutique,
        'adresse': adresse,
        'ville': ville,
        'telephoneBoutique': telephoneBoutique,
      });
    }

    await batch.commit();
    return userMisAJour;
  }

  Future<void> changerMotDePasse({
    required User user,
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    final userAuth = _auth.currentUser;
    if (userAuth == null) {
      throw StateError("Aucun utilisateur connecte.");
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: emailTechniqueDepuisTelephone(user.telephone),
      password: ancienMotDePasse,
    );

    await userAuth.reauthenticateWithCredential(credential);
    await userAuth.updatePassword(nouveauMotDePasse);
  }
}
