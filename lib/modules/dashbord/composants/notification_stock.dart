import 'package:flutter/material.dart';
import '../../produits/logique/stock_controller.dart';

class NotificationStock extends StatelessWidget {
  final StockController controller;
  final Color couleurIcone;

  const NotificationStock({
    super.key,
    required this.controller,
    this.couleurIcone = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final nbAlertes = controller.alertesCritiques.length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: couleurIcone,
              size: 26,
            ),
            if (nbAlertes > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444), // Rouge rupture
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$nbAlertes',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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