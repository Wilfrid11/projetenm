import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../coeur/firebase/firebase_collections.dart';
import 'notification_app.dart';

class DepotNotificationsFirebase {
  final FirebaseFirestore _firestore;

  DepotNotificationsFirebase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notifications(String boutiqueId) {
    return _firestore
        .collection(FirebaseCollections.boutiques)
        .doc(boutiqueId)
        .collection('notifications');
  }

  Stream<List<NotificationApp>> ecouterNotifications({
    required String boutiqueId,
    required String role,
  }) {
    return _notifications(boutiqueId).snapshots().map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => NotificationApp.fromMap(doc.id, doc.data()))
          .where((notification) => notification.visiblePourRole(role))
          .toList();

      notifications.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      return notifications;
    });
  }

  Future<void> creerNotification(NotificationApp notification) async {
    await _notifications(notification.boutiqueId).add(notification.toMap());
  }

  Future<void> marquerCommeLue({
    required String boutiqueId,
    required String notificationId,
  }) async {
    await _notifications(boutiqueId).doc(notificationId).update({'lu': true});
  }

  Future<void> marquerToutCommeLu({
    required String boutiqueId,
    required List<NotificationApp> notifications,
  }) async {
    final batch = _firestore.batch();

    for (final notification in notifications.where((item) => !item.lu)) {
      batch.update(_notifications(boutiqueId).doc(notification.id), {
        'lu': true,
      });
    }

    await batch.commit();
  }
}
