import 'package:flutter/material.dart';

import '../../../coeur/theme/theme_quinca.dart';
import '../data/notification_app.dart';
import '../logique/notifications_controller.dart';

class NotificationsPage extends StatelessWidget {
  final NotificationsController controller;

  const NotificationsPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          appBar: AppBar(
            title: const Text("Notifications"),
            backgroundColor: ThemeQuinca.bleuPrincipal,
            foregroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed:
                    controller.nonLues == 0 ? null : controller.marquerToutCommeLu,
                child: const Text(
                  "Tout lire",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.notifications.isEmpty
                  ? Center(
                      child: Text(
                        "Aucune notification pour le moment.",
                        style: ThemeQuinca.corpsTexte,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return _CarteNotification(
                          notification: notification,
                          onTap: () => controller.marquerCommeLue(notification),
                        );
                      },
                    ),
        );
      },
    );
  }
}

class _CarteNotification extends StatelessWidget {
  final NotificationApp notification;
  final VoidCallback onTap;

  const _CarteNotification({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = notification.lu ? ThemeQuinca.texteSecondaire : ThemeQuinca.bleuPrincipal;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.lu ? ThemeQuinca.bordure : ThemeQuinca.bleuPrincipal,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: couleur.withValues(alpha: 0.12),
          child: Icon(_iconeNotification(notification.type), color: couleur),
        ),
        title: Text(
          notification.titre,
          style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(notification.message, style: ThemeQuinca.corpsTexte),
        ),
        trailing: notification.lu
            ? null
            : const Icon(Icons.circle, size: 10, color: ThemeQuinca.rupture),
      ),
    );
  }
}

IconData _iconeNotification(String type) {
  switch (type) {
    case 'vente':
      return Icons.point_of_sale_outlined;
    case 'arrivage':
      return Icons.inventory_2_outlined;
    case 'stock':
      return Icons.warning_amber_rounded;
    case 'abonnement':
      return Icons.workspace_premium_outlined;
    default:
      return Icons.notifications_none_rounded;
  }
}
