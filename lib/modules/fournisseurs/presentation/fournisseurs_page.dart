import 'package:flutter/material.dart';

import '../../../coeur/composants/btn_principal.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../auth/data/user.dart';
import '../data/fournisseur.dart';
import '../logique/fournisseur_controller.dart';

class FournisseursPage extends StatefulWidget {
  final User user;

  const FournisseursPage({super.key, required this.user});

  @override
  State<FournisseursPage> createState() => _FournisseursPageState();
}

class _FournisseursPageState extends State<FournisseursPage> {
  final FournisseurController _controller = FournisseurController();

  @override
  void initState() {
    super.initState();
    _controller.charger(widget.user.boutiqueId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        foregroundColor: Colors.white,
        title: const Text("Fournisseurs"),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.fournisseurs.isEmpty) {
            return Center(
              child: Text(
                "Aucun fournisseur ajoute.",
                style: ThemeQuinca.corpsTexte,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.fournisseurs.length,
            itemBuilder: (context, index) {
              final fournisseur = _controller.fournisseurs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: ThemeQuinca.bordure),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: ThemeQuinca.fondGris,
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: ThemeQuinca.bleuPrincipal,
                    ),
                  ),
                  title: Text(
                    fournisseur.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    [
                      if (fournisseur.telephone.isNotEmpty)
                        fournisseur.telephone,
                      if (fournisseur.adresse.isNotEmpty) fournisseur.adresse,
                    ].join(" • "),
                  ),
                  onTap: () => _ouvrirFormulaire(fournisseur: fournisseur),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: ThemeQuinca.rupture,
                    ),
                    onPressed: () => _confirmerDesactivation(fournisseur),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        onPressed: () => _ouvrirFormulaire(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _ouvrirFormulaire({Fournisseur? fournisseur}) {
    final nomCtrl = TextEditingController(text: fournisseur?.nom ?? '');
    final telCtrl = TextEditingController(text: fournisseur?.telephone ?? '');
    final adresseCtrl = TextEditingController(text: fournisseur?.adresse ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fournisseur == null
                    ? "Ajouter un fournisseur"
                    : "Modifier le fournisseur",
                style: ThemeQuinca.titrePrincipal,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nomCtrl,
                decoration: ThemeQuinca.inputDecoration(
                  label: "Nom du fournisseur",
                  icone: Icons.business_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telCtrl,
                keyboardType: TextInputType.phone,
                decoration: ThemeQuinca.inputDecoration(
                  label: "Telephone",
                  icone: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adresseCtrl,
                decoration: ThemeQuinca.inputDecoration(
                  label: "Adresse",
                  icone: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 20),
              BtnPrincipal(
                texte: fournisseur == null ? "Ajouter" : "Enregistrer",
                onPressed: () async {
                  final navigator = Navigator.of(sheetContext);
                  final messenger = ScaffoldMessenger.of(context);
                  final nom = nomCtrl.text.trim();
                  if (nom.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Le nom est obligatoire.")),
                    );
                    return;
                  }

                  final data = Fournisseur(
                    id: fournisseur?.id ?? '',
                    boutiqueId: widget.user.boutiqueId,
                    nom: nom,
                    telephone: telCtrl.text.trim(),
                    adresse: adresseCtrl.text.trim(),
                    actif: true,
                    createdAt: fournisseur?.createdAt,
                  );

                  final succes = fournisseur == null
                      ? await _controller.ajouter(data)
                      : await _controller.modifier(data);

                  if (!mounted) return;
                  if (succes) {
                    navigator.pop();
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          _controller.erreur ?? "Operation impossible.",
                        ),
                        backgroundColor: ThemeQuinca.rupture,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmerDesactivation(Fournisseur fournisseur) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Masquer ce fournisseur ?"),
        content: const Text(
          "Le fournisseur ne sera plus propose dans les arrivages, mais ses anciens arrivages resteront visibles.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Masquer"),
          ),
        ],
      ),
    );

    if (confirmer == true) {
      await _controller.desactiver(fournisseur);
    }
  }
}
