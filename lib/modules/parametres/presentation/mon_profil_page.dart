import 'package:flutter/material.dart';

import '../../../coeur/theme/theme_quinca.dart';
import '../../auth/data/user.dart';

class MonProfilPage extends StatelessWidget {
  final User user;

  const MonProfilPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        title: const Text("Mon profil"),
        backgroundColor: ThemeQuinca.bleuPrincipal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _EnteteProfil(user: user),
          const SizedBox(height: 16),
          _InfoProfil(
            icone: Icons.person_outline,
            titre: "Nom",
            valeur: user.nom,
          ),
          _InfoProfil(
            icone: Icons.badge_outlined,
            titre: "Prenom",
            valeur: user.prenom,
          ),
          _InfoProfil(
            icone: Icons.phone_outlined,
            titre: "Telephone",
            valeur: user.telephone,
          ),
          _InfoProfil(
            icone: Icons.verified_user_outlined,
            titre: "Role",
            valeur: user.role.toUpperCase(),
          ),
          _InfoProfil(
            icone: Icons.storefront_outlined,
            titre: "Boutique",
            valeur: user.nomBoutique,
          ),
        ],
      ),
    );
  }
}

class _EnteteProfil extends StatelessWidget {
  final User user;

  const _EnteteProfil({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeQuinca.bleuPrincipal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_outline, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.prenom} ${user.nom}",
                  style: ThemeQuinca.titrePrincipal.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role.toUpperCase(),
                  style: ThemeQuinca.corpsTexte.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoProfil extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String valeur;

  const _InfoProfil({
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: ListTile(
        leading: Icon(icone, color: ThemeQuinca.bleuPrincipal),
        title: Text(titre, style: ThemeQuinca.corpsTexte),
        subtitle: Text(
          valeur.isEmpty ? "Non renseigne" : valeur,
          style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}
