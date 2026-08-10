import 'package:flutter/material.dart';

import '../../../coeur/theme/theme_mode_controller.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../auth/data/user.dart';
import '../../auth/logique/hook.dart';
import '../logique/parametres_controller.dart';

enum SectionParametres {
  boutique,
  personnel,
  securite,
  abonnement,
  apparence,
}

class ParametresPage extends StatefulWidget {
  final User user;
  final HookAuth authHook;
  final SectionParametres? sectionInitiale;

  const ParametresPage({
    super.key,
    required this.user,
    required this.authHook,
    this.sectionInitiale,
  });

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  late final ParametresController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ParametresController(user: widget.user);
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
        final user = _controller.user;
        final sections = user.isAdmin
            ? SectionParametres.values
            : const [
                SectionParametres.personnel,
                SectionParametres.securite,
                SectionParametres.apparence,
              ];

        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          appBar: AppBar(
            title: const Text("Parametres"),
            backgroundColor: ThemeQuinca.bleuPrincipal,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _EnteteParametres(user: user),
              const SizedBox(height: 16),
              for (final section in sections)
                _CarteSectionParametres(
                  section: section,
                  miseEnAvant: section == widget.sectionInitiale,
                  onTap: () => _ouvrirSection(section),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _ouvrirSection(SectionParametres section) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _DetailSectionParametres(
          controller: _controller,
          authHook: widget.authHook,
          section: section,
        ),
      ),
    );
    widget.authHook.synchroniserUtilisateur(_controller.user);
  }
}

class _DetailSectionParametres extends StatefulWidget {
  final ParametresController controller;
  final HookAuth authHook;
  final SectionParametres section;

  const _DetailSectionParametres({
    required this.controller,
    required this.authHook,
    required this.section,
  });

  @override
  State<_DetailSectionParametres> createState() =>
      _DetailSectionParametresState();
}

class _DetailSectionParametresState extends State<_DetailSectionParametres> {
  final _nomBoutiqueCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _telephoneBoutiqueCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _ancienMotDePasseCtrl = TextEditingController();
  final _nouveauMotDePasseCtrl = TextEditingController();
  final _confirmationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = widget.controller.user;
    _nomBoutiqueCtrl.text = user.nomBoutique;
    _adresseCtrl.text = user.adresse;
    _villeCtrl.text = user.ville;
    _telephoneBoutiqueCtrl.text = user.telephoneBoutique;
    _nomCtrl.text = user.nom;
    _prenomCtrl.text = user.prenom;
  }

  @override
  void dispose() {
    _nomBoutiqueCtrl.dispose();
    _adresseCtrl.dispose();
    _villeCtrl.dispose();
    _telephoneBoutiqueCtrl.dispose();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _ancienMotDePasseCtrl.dispose();
    _nouveauMotDePasseCtrl.dispose();
    _confirmationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: ThemeQuinca.fondGris,
          appBar: AppBar(
            title: Text(_titreSection(widget.section)),
            backgroundColor: ThemeQuinca.bleuPrincipal,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: _contenuSection(),
          ),
        );
      },
    );
  }

  List<Widget> _contenuSection() {
    switch (widget.section) {
      case SectionParametres.boutique:
        return [
          _ChampParametre(
            controller: _nomBoutiqueCtrl,
            label: "Nom de la boutique",
            icone: Icons.storefront_outlined,
          ),
          _ChampParametre(
            controller: _adresseCtrl,
            label: "Adresse",
            icone: Icons.place_outlined,
          ),
          _ChampParametre(
            controller: _villeCtrl,
            label: "Ville",
            icone: Icons.location_city_outlined,
          ),
          _ChampParametre(
            controller: _telephoneBoutiqueCtrl,
            label: "Telephone boutique",
            icone: Icons.phone_outlined,
            type: TextInputType.phone,
          ),
          _BoutonSauvegarde(
            loading: widget.controller.isLoading,
            texte: "Enregistrer la boutique",
            onPressed: _sauverBoutique,
          ),
        ];
      case SectionParametres.personnel:
        return [
          _ChampParametre(
            controller: _nomCtrl,
            label: "Nom",
            icone: Icons.person_outline,
          ),
          _ChampParametre(
            controller: _prenomCtrl,
            label: "Prenom",
            icone: Icons.badge_outlined,
          ),
          _ChampLecture(
            icone: Icons.phone_outlined,
            titre: "Telephone",
            valeur: widget.controller.user.telephone,
          ),
          const _AlerteInfo(
            texte:
                "Le telephone reste bloque car il sert a la connexion Firebase.",
          ),
          _BoutonSauvegarde(
            loading: widget.controller.isLoading,
            texte: "Enregistrer mes infos",
            onPressed: _sauverPersonnel,
          ),
        ];
      case SectionParametres.securite:
        return [
          _ChampParametre(
            controller: _ancienMotDePasseCtrl,
            label: "Ancien mot de passe",
            icone: Icons.lock_outline,
            type: TextInputType.number,
            obscure: true,
          ),
          _ChampParametre(
            controller: _nouveauMotDePasseCtrl,
            label: "Nouveau mot de passe",
            icone: Icons.password_outlined,
            type: TextInputType.number,
            obscure: true,
          ),
          _ChampParametre(
            controller: _confirmationCtrl,
            label: "Confirmer",
            icone: Icons.verified_outlined,
            type: TextInputType.number,
            obscure: true,
          ),
          const _AlerteInfo(
            texte: "Le mot de passe doit contenir exactement 6 chiffres.",
          ),
          _BoutonSauvegarde(
            loading: widget.controller.isLoading,
            texte: "Changer le mot de passe",
            onPressed: _changerMotDePasse,
          ),
        ];
      case SectionParametres.abonnement:
        return const [
          _ChampLecture(
            icone: Icons.workspace_premium_outlined,
            titre: "Forfait",
            valeur: "Gratuit",
          ),
          _ChampLecture(
            icone: Icons.check_circle_outline,
            titre: "Statut",
            valeur: "Actif",
          ),
          _ChampLecture(
            icone: Icons.event_outlined,
            titre: "Validite",
            valeur: "Non definie",
          ),
          _AlerteInfo(
            texte:
                "Le suivi d'abonnement est pret cote interface. Le paiement sera branche plus tard.",
          ),
        ];
      case SectionParametres.apparence:
        return [
          _OptionApparence(
            icone: Icons.light_mode_outlined,
            titre: "Mode clair",
            mode: ThemeMode.light,
          ),
          _OptionApparence(
            icone: Icons.dark_mode_outlined,
            titre: "Mode sombre",
            mode: ThemeMode.dark,
          ),
          _OptionApparence(
            icone: Icons.settings_suggest_outlined,
            titre: "Systeme",
            mode: ThemeMode.system,
          ),
          const _AlerteInfo(
            texte:
                "Le choix est applique tout de suite. Il sera rendu persistant quand on ajoutera le stockage local.",
          ),
        ];
    }
  }

  Future<void> _sauverBoutique() async {
    final succes = await widget.controller.modifierInfosBoutique(
      nomBoutique: _nomBoutiqueCtrl.text,
      adresse: _adresseCtrl.text,
      ville: _villeCtrl.text,
      telephoneBoutique: _telephoneBoutiqueCtrl.text,
    );
    _apresAction(succes, "Informations boutique mises a jour.");
  }

  Future<void> _sauverPersonnel() async {
    final succes = await widget.controller.modifierInfosPersonnelles(
      nom: _nomCtrl.text,
      prenom: _prenomCtrl.text,
    );
    _apresAction(succes, "Informations personnelles mises a jour.");
  }

  Future<void> _changerMotDePasse() async {
    final succes = await widget.controller.changerMotDePasse(
      ancienMotDePasse: _ancienMotDePasseCtrl.text.trim(),
      nouveauMotDePasse: _nouveauMotDePasseCtrl.text.trim(),
      confirmation: _confirmationCtrl.text.trim(),
    );
    if (succes) {
      _ancienMotDePasseCtrl.clear();
      _nouveauMotDePasseCtrl.clear();
      _confirmationCtrl.clear();
    }
    _apresAction(succes, "Mot de passe modifie.");
  }

  void _apresAction(bool succes, String messageSucces) {
    if (!mounted) return;
    widget.authHook.synchroniserUtilisateur(widget.controller.user);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(succes
            ? messageSucces
            : widget.controller.erreur ?? "Operation impossible."),
        backgroundColor: succes ? ThemeQuinca.succes : ThemeQuinca.rupture,
      ),
    );
  }
}

class _EnteteParametres extends StatelessWidget {
  final User user;

  const _EnteteParametres({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: ThemeQuinca.bleuPrincipal,
            child: Icon(Icons.settings_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nomBoutique.isEmpty ? "QuincaPro" : user.nomBoutique,
                  style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  "${user.prenom} ${user.nom} - ${user.role.toUpperCase()}",
                  style: ThemeQuinca.corpsTexte.copyWith(
                    color: ThemeQuinca.texteSecondaire,
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

class _CarteSectionParametres extends StatelessWidget {
  final SectionParametres section;
  final bool miseEnAvant;
  final VoidCallback onTap;

  const _CarteSectionParametres({
    required this.section,
    required this.miseEnAvant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = miseEnAvant ? ThemeQuinca.bleuPrincipal : Colors.white;
    final couleurTexte = miseEnAvant ? Colors.white : ThemeQuinca.texteFonce;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: miseEnAvant ? ThemeQuinca.bleuPrincipal : ThemeQuinca.bordure,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(_iconeSection(section), color: couleurTexte),
        title: Text(
          _titreSection(section),
          style: ThemeQuinca.titrePrincipal.copyWith(
            color: couleurTexte,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _descriptionSection(section),
          style: ThemeQuinca.corpsTexte.copyWith(
            color: miseEnAvant ? Colors.white70 : ThemeQuinca.texteSecondaire,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: couleurTexte),
      ),
    );
  }
}

class _ChampParametre extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icone;
  final TextInputType type;
  final bool obscure;

  const _ChampParametre({
    required this.controller,
    required this.label,
    required this.icone,
    this.type = TextInputType.text,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        maxLength: type == TextInputType.number ? 6 : null,
        decoration: ThemeQuinca.inputDecoration(label: label, icone: icone),
      ),
    );
  }
}

class _BoutonSauvegarde extends StatelessWidget {
  final bool loading;
  final String texte;
  final VoidCallback onPressed;

  const _BoutonSauvegarde({
    required this.loading,
    required this.texte,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(loading ? "Enregistrement..." : texte),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeQuinca.bleuPrincipal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _ChampLecture extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String valeur;

  const _ChampLecture({
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

class _AlerteInfo extends StatelessWidget {
  final String texte;

  const _AlerteInfo({required this.texte});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeQuinca.bleuPrincipal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ThemeQuinca.bleuPrincipal.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: ThemeQuinca.bleuPrincipal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texte,
              style: ThemeQuinca.corpsTexte.copyWith(
                color: ThemeQuinca.texteFonce,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionApparence extends StatelessWidget {
  final IconData icone;
  final String titre;
  final ThemeMode mode;

  const _OptionApparence({
    required this.icone,
    required this.titre,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeModeController.mode,
      builder: (context, modeActuel, _) {
        final actif = modeActuel == mode;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: actif ? ThemeQuinca.bleuPrincipal : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: actif ? ThemeQuinca.bleuPrincipal : ThemeQuinca.bordure,
            ),
          ),
          child: ListTile(
            onTap: () => ThemeModeController.changer(mode),
            leading: Icon(
              icone,
              color: actif ? Colors.white : ThemeQuinca.bleuPrincipal,
            ),
            title: Text(
              titre,
              style: ThemeQuinca.titrePrincipal.copyWith(
                fontSize: 16,
                color: actif ? Colors.white : ThemeQuinca.texteFonce,
              ),
            ),
            trailing: Icon(
              actif ? Icons.radio_button_checked : Icons.radio_button_off,
              color: actif ? Colors.white : ThemeQuinca.texteSecondaire,
            ),
          ),
        );
      },
    );
  }
}

IconData _iconeSection(SectionParametres section) {
  switch (section) {
    case SectionParametres.boutique:
      return Icons.storefront_outlined;
    case SectionParametres.personnel:
      return Icons.person_outline;
    case SectionParametres.securite:
      return Icons.lock_outline;
    case SectionParametres.abonnement:
      return Icons.workspace_premium_outlined;
    case SectionParametres.apparence:
      return Icons.dark_mode_outlined;
  }
}

String _titreSection(SectionParametres section) {
  switch (section) {
    case SectionParametres.boutique:
      return "Informations boutique";
    case SectionParametres.personnel:
      return "Informations personnelles";
    case SectionParametres.securite:
      return "Securite";
    case SectionParametres.abonnement:
      return "Abonnement";
    case SectionParametres.apparence:
      return "Apparence";
  }
}

String _descriptionSection(SectionParametres section) {
  switch (section) {
    case SectionParametres.boutique:
      return "Nom, adresse, ville et telephone de la boutique";
    case SectionParametres.personnel:
      return "Nom, prenom et informations de compte";
    case SectionParametres.securite:
      return "Modification du mot de passe";
    case SectionParametres.abonnement:
      return "Forfait, statut et validite";
    case SectionParametres.apparence:
      return "Mode clair, sombre ou systeme";
  }
}
