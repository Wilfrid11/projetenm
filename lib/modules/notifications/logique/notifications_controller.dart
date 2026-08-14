import 'dart:async';

import 'package:flutter/material.dart';

import '../data/depot_notifications_firebase.dart';
import '../data/notification_app.dart';

class NotificationsController extends ChangeNotifier {
  final DepotNotificationsFirebase _depot;
  final String boutiqueId;
  final String role;

  StreamSubscription<List<NotificationApp>>? _subscription;
  List<NotificationApp> _notifications = const [];
  bool _isLoading = true;

  NotificationsController({
    required this.boutiqueId,
    required this.role,
    DepotNotificationsFirebase? depot,
  }) : _depot = depot ?? DepotNotificationsFirebase() {
    _ecouter();
  }

  List<NotificationApp> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get nonLues => _notifications.where((item) => !item.lu).length;

  void _ecouter() {
    _subscription = _depot
        .ecouterNotifications(boutiqueId: boutiqueId, role: role)
        .listen((notifications) {
      _notifications = notifications;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> marquerCommeLue(NotificationApp notification) async {
    if (notification.lu) return;

    await _depot.marquerCommeLue(
      boutiqueId: boutiqueId,
      notificationId: notification.id,
    );
  }

  Future<void> marquerToutCommeLu() async {
    await _depot.marquerToutCommeLu(
      boutiqueId: boutiqueId,
      notifications: _notifications,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
