import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';

import '../../../coeur/firebase/firebase_collections.dart';
import '../../../firebase_options.dart';
import '../logique/telephone_utils.dart';
import 'boutique.dart';
import 'user.dart';

class DepotAuthFirebase {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DepotAuthFirebase({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User?> authentifier(String telephone, String motDePasse) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: emailTechniqueDepuisTelephone(telephone),
      password: motDePasse,
    );

    final uid = credential.user?.uid;
    if (uid == null) return null;

    return chargerUtilisateur(uid);
  }

  Future<User?> chargerUtilisateur(String uid) async {
    final snapshot = await _firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .get();

    final data = snapshot.data();
    if (data == null) return null;

    return User.fromMap(data);
  }

  Future<User?> inscrireAdmin({
    required String nom,
    required String prenom,
    required String telephone,
    required String nomBoutique,
    required String adresse,
    required String ville,
    required String telephoneBoutique,
    required String motDePasse,
  }) async {
    final telephoneNormalise = normaliserTelephoneBenin(telephone);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: emailTechniqueDepuisTelephone(telephoneNormalise),
      password: motDePasse,
    );

    final uid = credential.user!.uid;
    final boutiqueId = _firestore.collection(FirebaseCollections.boutiques).doc().id;

    final user = User(
      id: uid,
      nom: nom,
      prenom: prenom,
      telephone: telephoneNormalise,
      role: 'admin',
      boutiqueId: boutiqueId,
      nomBoutique: nomBoutique,
      adresse: adresse,
      ville: ville,
      telephoneBoutique: telephoneBoutique,
      actif: true,
      mustChangePassword: false,
    );

    final boutique = Boutique(
      id: boutiqueId,
      nom: nomBoutique,
      adresse: adresse,
      ville: ville,
      telephone: telephoneBoutique,
      ownerId: uid,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(
      _firestore.collection(FirebaseCollections.users).doc(uid),
      user.toMap(),
    );
    batch.set(
      _firestore.collection(FirebaseCollections.boutiques).doc(boutiqueId),
      boutique.toMap(),
    );
    await batch.commit();

    return user;
  }

  Future<User?> creerGerant({
    required User gerant,
    required String motDePasseTemporaire,
  }) async {
    final creationAuth = await _authCreationCompte();
    final telephoneNormalise = normaliserTelephoneBenin(gerant.telephone);
    final credential = await creationAuth.createUserWithEmailAndPassword(
      email: emailTechniqueDepuisTelephone(telephoneNormalise),
      password: motDePasseTemporaire,
    );

    final uid = credential.user!.uid;
    final user = User(
      id: uid,
      nom: gerant.nom,
      prenom: gerant.prenom,
      telephone: telephoneNormalise,
      role: 'gerant',
      boutiqueId: gerant.boutiqueId,
      nomBoutique: gerant.nomBoutique,
      adresse: gerant.adresse,
      ville: gerant.ville,
      telephoneBoutique: gerant.telephoneBoutique,
      actif: true,
      mustChangePassword: true,
    );

    await _firestore.collection(FirebaseCollections.users).doc(uid).set(
          user.toMap(),
        );

    await creationAuth.signOut();
    return user;
  }

  Future<List<User>> utilisateursBoutique(String boutiqueId) async {
    final snapshot = await _firestore
        .collection(FirebaseCollections.users)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .where('role', isEqualTo: 'gerant')
        .get();

    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  Future<bool> changerMotDePasse(String nouveauMotDePasse) async {
    final userAuth = _auth.currentUser;
    if (userAuth == null) return false;

    await userAuth.updatePassword(nouveauMotDePasse);
    await _firestore
        .collection(FirebaseCollections.users)
        .doc(userAuth.uid)
        .update({'mustChangePassword': false});
    return true;
  }

  Future<void> supprimerUtilisateur(User user) async {
    await _firestore
        .collection(FirebaseCollections.users)
        .doc(user.id)
        .update({'actif': false});
  }

  Future<void> deconnecter() => _auth.signOut();

  Future<firebase_auth.FirebaseAuth> _authCreationCompte() async {
    const appName = 'quinca-pro-user-creation';

    try {
      final app = Firebase.app(appName);
      return firebase_auth.FirebaseAuth.instanceFor(app: app);
    } catch (_) {
      final app = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return firebase_auth.FirebaseAuth.instanceFor(app: app);
    }
  }
}
