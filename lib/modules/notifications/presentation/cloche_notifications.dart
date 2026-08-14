import 'package:flutter/material.dart';

import '../../../coeur/theme/theme_quinca.dart';
import '../../auth/data/user.dart';
import '../logique/notifications_controller.dart';
import 'notifications_page.dart';

class ClocheNotifications extends StatefulWidget {
  final User user;
  final Color couleur;

  const ClocheNotifications({
    super.key,
    required this.user,
    this.couleur = Colors.white,
  });

  @override
  State<ClocheNotifications> createState() => _ClocheNotificationsState();
}

class _ClocheNotificationsState extends State<ClocheNotifications> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController(
      boutiqueId: widget.user.boutiqueId,
      role: widget.user.role,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: "Notifications",
              icon: Icon(Icons.notifications_none_rounded, color: widget.couleur),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(
                      controller: _controller,
                    ),
                  ),
                );
              },
            ),
            if (_controller.nonLues > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: ThemeQuinca.rupture,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _controller.nonLues > 9 ? '9+' : '${_controller.nonLues}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
