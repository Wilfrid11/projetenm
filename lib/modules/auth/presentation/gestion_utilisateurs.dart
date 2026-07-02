// lib/modules/auth/presentation/gestion_utilisateurs.dart

import 'package:flutter/material.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../../coeur/composants/btn_principal.dart';
import '../logique/user_controller.dart';
import '../data/user.dart';
import '../logique/telephone_utils.dart';

class GestionUtilisateursPage extends StatefulWidget {
  final UserController userController;
  final User admin;

  const GestionUtilisateursPage(
      {super.key, required this.userController, required this.admin});

  @override
  State<GestionUtilisateursPage> createState() => _GestionUtilisateursPageState();
}

class _GestionUtilisateursPageState extends State<GestionUtilisateursPage> {
  @override
  void initState() {
    super.initState();
    widget.userController.chargerUtilisateursBoutique(widget.admin.boutiqueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        title: Text("Gestion des Utilisateurs",
            style: ThemeQuinca.titrePrincipal
                .copyWith(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: widget.userController,
        builder: (context, _) {
          final employes =
              widget.userController.utilisateursBoutique(widget.admin.boutiqueId);

          if (employes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 80,
                      color:
                          ThemeQuinca.texteSecondaire.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text("Aucun gérant ajouté",
                      style: ThemeQuinca.titrePrincipal),
                  Text("Ajoutez vos employés pour qu'ils puissent vendre",
                      style: ThemeQuinca.corpsTexte),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: ThemeQuinca.bordure)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: ThemeQuinca.fondGris,
                    child: Icon(Icons.person, color: ThemeQuinca.bleuPrincipal),
                  ),
                  title: Text("${user.prenom} ${user.nom}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.telephone, style: ThemeQuinca.corpsTexte),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: ThemeQuinca.rupture),
                    onPressed: () =>
                        widget.userController.supprimerUtilisateur(user.id),
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
    final pageContext = context;
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ajouter un Gérant", style: ThemeQuinca.titrePrincipal),
              const SizedBox(height: 8),
              Text(
                  "L'app générera un mot de passe temporaire à 6 chiffres.",
                  style: ThemeQuinca.corpsTexte),
              const SizedBox(height: 24),
              TextField(
                  controller: nomCtrl,
                  decoration: ThemeQuinca.inputDecoration(
                      label: "Nom", icone: Icons.person_outline)),
              const SizedBox(height: 16),
              TextField(
                  controller: prenomCtrl,
                  decoration: ThemeQuinca.inputDecoration(
                      label: "Prénom", icone: Icons.badge_outlined)),
              const SizedBox(height: 16),
              TextField(
                  controller: telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: ThemeQuinca.inputDecoration(
                      label: "Téléphone", icone: Icons.phone_android)),
              const SizedBox(height: 16),
              const SizedBox(height: 8),
              BtnPrincipal(
                  texte: "Créer le compte",
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    if (nomCtrl.text.isEmpty ||
                        telCtrl.text.isEmpty ||
                        !telephoneBeninValide(telCtrl.text)) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Nom et téléphone valide requis (ex: 0197000000)",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final motDePasseTemporaire =
                        await widget.userController.ajouterGerant(
                      User(
                        id: "USR-${DateTime.now().millisecondsSinceEpoch}",
                        nom: nomCtrl.text.trim(),
                        prenom: prenomCtrl.text.trim(),
                        telephone: normaliserTelephoneBenin(telCtrl.text),
                        role: "gerant",
                        boutiqueId: widget.admin.boutiqueId,
                        nomBoutique: widget.admin.nomBoutique,
                        adresse: widget.admin.adresse,
                        ville: widget.admin.ville,
                        telephoneBoutique: widget.admin.telephoneBoutique,
                        actif: true,
                        mustChangePassword: true,
                      ),
                    );

                    if (motDePasseTemporaire == null) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Ce téléphone est déjà utilisé"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (!pageContext.mounted) return;
                    navigator.pop();
                    _afficherMotDePasseTemporaire(
                      pageContext,
                      telephone: normaliserTelephoneBenin(telCtrl.text),
                      motDePasse: motDePasseTemporaire,
                    );
                  }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _afficherMotDePasseTemporaire(
    BuildContext context, {
    required String telephone,
    required String motDePasse,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Compte gérant créé"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Téléphone : $telephone"),
            const SizedBox(height: 8),
            Text("Mot de passe temporaire : $motDePasse"),
            const SizedBox(height: 16),
            const Text(
              "Communiquez ce mot de passe au gérant. Il devra le changer à sa première connexion.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
