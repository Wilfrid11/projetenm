// lib/modules/produits/composants/menu_lateral.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../coeur/theme/theme_quinca.dart';
import '../../auth/data/user.dart';
import '../logique/stock_controller.dart';
import '../presentation/onglets/arrivage.dart';
import '../presentation/onglets/catalogue.dart';
import '../presentation/onglets/historique_entrees.dart';

class MenuLateral extends StatelessWidget {
  final StockController stockController;
  final User user;

  const MenuLateral({
    super.key,
    required this.stockController,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EnteteDrawer(user: user),
            const SizedBox(height: 10),
            if (user.isAdmin)
              _ElementMenu(
                icone: Icons.playlist_add_rounded,
                titre: "Catalogue",
                description: "Creer les fiches produits",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CataloguePage(
                        controller: stockController,
                        user: user,
                      ),
                    ),
                  );
                },
              ),
            _ElementMenu(
              icone: Icons.input_rounded,
              titre: "Arrivage",
              description: "Ajouter les entrees de stock",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArrivagePage(
                      controller: stockController,
                      user: user,
                    ),
                  ),
                );
              },
            ),
            _ElementMenu(
              icone: Icons.history_rounded,
              titre: "Historique",
              description: "Consulter les entrees passees",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoriqueEntreesPage(
                      controller: stockController,
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Catalogue reserve a l'admin. Arrivage et historique disponibles selon le role.",
                style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnteteDrawer extends StatelessWidget {
  final User user;

  const _EnteteDrawer({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: ThemeQuinca.bleuPrincipal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(Icons.inventory_2_outlined, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            "Gestion produits",
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.role.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementMenu extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String description;
  final VoidCallback onTap;

  const _ElementMenu({
    required this.icone,
    required this.titre,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: ThemeQuinca.bleuPrincipal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icone, color: ThemeQuinca.bleuPrincipal),
      ),
      title: Text(
        titre,
        style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16),
      ),
      subtitle: Text(description, style: ThemeQuinca.corpsTexte),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
