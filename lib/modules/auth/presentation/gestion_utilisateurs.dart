// lib/modules/auth/presentation/gestion_utilisateurs.dart

import 'package:flutter/material.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../../coeur/composants/btn_principal.dart';
import '../logique/user_controller.dart';
import '../data/user.dart';

class GestionUtilisateursPage extends StatelessWidget {
  final UserController userController;
  final User admin;

  const GestionUtilisateursPage({
    super.key, 
    required this.userController, 
    required this.admin
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        title: Text("Gestion des Utilisateurs", 
          style: ThemeQuinca.titrePrincipal.copyWith(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: userController,
        builder: (context, _) {
          final employes = userController.utilisateursBoutique(admin.boutiqueId);

          if (employes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: ThemeQuinca.texteSecondaire.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text("Aucun gérant ajouté", style: ThemeQuinca.titrePrincipal),
                  Text("Ajoutez vos employés pour qu'ils puissent vendre", style: ThemeQuinca.corpsTexte),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employes.length,
            itemBuilder: (context, index) {
              final user = employes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: ThemeQuinca.bordure)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: ThemeQuinca.fondGris,
                    child: Icon(Icons.person, color: ThemeQuinca.bleuPrincipal),
                  ),
                  title: Text("${user.prenom} ${user.nom}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.telephone, style: ThemeQuinca.corpsTexte),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: ThemeQuinca.rupture),
                    onPressed: () => userController.supprimerUtilisateur(user.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        onPressed: () => _ouvrirFormulaireAjout(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _ouvrirFormulaireAjout(BuildContext context) {
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final pinCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24, left: 24, right: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ajouter un Gérant", style: ThemeQuinca.titrePrincipal),
              const SizedBox(height: 8),
              Text("Le gérant pourra se connecter avec son téléphone et son code PIN.", style: ThemeQuinca.corpsTexte),
              const SizedBox(height: 24),
              TextField(
                controller: nomCtrl, 
                decoration: ThemeQuinca.inputDecoration(label: "Nom", icone: Icons.person_outline)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prenomCtrl, 
                decoration: ThemeQuinca.inputDecoration(label: "Prénom", icone: Icons.badge_outlined)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: telCtrl, 
                keyboardType: TextInputType.phone,
                decoration: ThemeQuinca.inputDecoration(label: "Téléphone", icone: Icons.phone_android)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinCtrl, 
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: ThemeQuinca.inputDecoration(label: "Code PIN temporaire", icone: Icons.lock_outline)
              ),
              const SizedBox(height: 24),
              BtnPrincipal(
                texte: "Créer le compte", 
                onPressed: () {
                  if(nomCtrl.text.isNotEmpty && telCtrl.text.isNotEmpty) {
                    userController.ajouterGerant(User(
                      id: "USR-${DateTime.now().millisecondsSinceEpoch}",
                      nom: nomCtrl.text.trim(),
                      prenom: prenomCtrl.text.trim(),
                      telephone: telCtrl.text.trim(),
                      role: "gerant",
                      boutiqueId: admin.boutiqueId,
                      nomBoutique: admin.nomBoutique,
                      adresse: admin.adresse,
                      ville: admin.ville,
                      telephoneBoutique: admin.telephoneBoutique,
                      isFirstLogin: true,
                    ));
                    Navigator.pop(context);
                  }
                }
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}