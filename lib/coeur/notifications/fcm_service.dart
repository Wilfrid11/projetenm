import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../modules/auth/data/user.dart';

@pragma('vm:entry-point')
Future<void> gererMessageFirebaseEnArrierePlan(RemoteMessage message) async {
  // Handler requis par FCM quand Android reveille l'application en arriere-plan.
  // Si le message envoye contient un bloc "notification", Android l'affiche.
}

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _dernierToken;
  User? _utilisateurActuel;
  bool _ecouteRenouvellementToken = false;

  Future<void> initialiser() async {
    if (kIsWeb) return;

    FirebaseMessaging.onBackgroundMessage(gererMessageFirebaseEnArrierePlan);
    await _demanderPermission();

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        "Notification recue: ${message.notification?.title ?? message.messageId}",
      );
    });
  }

  Future<void> synchroniserTokenUtilisateur(User user) async {
    if (kIsWeb) return;

    _utilisateurActuel = user;
    await _demanderPermission();

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    _dernierToken = token;
    await _enregistrerToken(user: user, token: token);

    if (!_ecouteRenouvellementToken) {
      _ecouteRenouvellementToken = true;
      _messaging.onTokenRefresh.listen((nouveauToken) async {
        final utilisateur = _utilisateurActuel;
        if (utilisateur == null) return;

        _dernierToken = nouveauToken;
        await _enregistrerToken(user: utilisateur, token: nouveauToken);
      });
    }
  }

  Future<void> oublierTokenUtilisateur(User? user) async {
    if (kIsWeb) return;
    if (user == null || _dernierToken == null) return;

    await _firestore
        .collection('users')
        .doc(user.id)
        .collection('fcmTokens')
        .doc(_dernierToken)
        .set({
      'actif': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _utilisateurActuel = null;
  }

  Future<void> _demanderPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _enregistrerToken({
    required User user,
    required String token,
  }) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .collection('fcmTokens')
        .doc(token)
        .set({
      'token': token,
      'actif': true,
      'userId': user.id,
      'boutiqueId': user.boutiqueId,
      'role': user.role,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
