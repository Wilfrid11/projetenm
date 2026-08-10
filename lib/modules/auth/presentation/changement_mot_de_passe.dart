import 'package:flutter/material.dart';

import '../../../coeur/composants/btn_principal.dart';
import '../../../coeur/composants/pin_input.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../dashbord/presentation/role.dart';
import '../../produits/logique/stock_controller.dart';
import '../../ventes/logique/vente_controller.dart';
import '../data/user.dart';
import '../logique/hook.dart';
import '../logique/password_utils.dart';
import '../logique/user_controller.dart';

class ChangementMotDePassePage extends StatefulWidget {
  final HookAuth authHook;
  final User user;
  final StockController stockController;
  final VenteController venteController;
  final UserController userController;

  const ChangementMotDePassePage({
    super.key,
    required this.authHook,
    required this.user,
    required this.stockController,
    required this.venteController,
    required this.userController,
  });

  @override
  State<ChangementMotDePassePage> createState() =>
      _ChangementMotDePassePageState();
}

class _ChangementMotDePassePageState extends State<ChangementMotDePassePage> {
  final _nouveauController = TextEditingController();
  final _confirmationController = TextEditingController();
  String? _erreur;

  @override
  void dispose() {
    _nouveauController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    setState(() => _erreur = null);

    final nouveau = _nouveauController.text.trim();
    final confirmation = _confirmationController.text.trim();

    if (!motDePasseSixChiffresValide(nouveau) ||
        !motDePasseSixChiffresValide(confirmation)) {
      setState(() => _erreur = "Le mot de passe doit contenir 6 chiffres.");
      return;
    }

    if (nouveau != confirmation) {
      setState(() => _erreur = "Les deux mots de passe ne correspondent pas.");
      return;
    }

    final succes = await widget.authHook.changerMotDePasseObligatoire(nouveau);
    if (!mounted) return;

    if (!succes || widget.authHook.currentUser == null) {
      setState(() {
        _erreur = widget.authHook.errorMessage ??
            "Une erreur est survenue pendant la mise à jour.";
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RolePage(
          user: widget.authHook.currentUser!,
          stockController: widget.stockController,
          venteController: widget.venteController,
          userController: widget.userController,
          authHook: widget.authHook,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeQuinca.bordure),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_reset_rounded,
                  color: ThemeQuinca.bleuPrincipal,
                  size: 36,
                ),
                const SizedBox(height: 16),
                Text(
                  "Nouveau mot de passe",
                  style: ThemeQuinca.titrePrincipal,
                ),
                const SizedBox(height: 8),
                Text(
                  "Pour sécuriser votre compte, créez votre mot de passe personnel à 6 chiffres.",
                  style: ThemeQuinca.corpsTexte,
                ),
                const SizedBox(height: 28),
                Text(
                  "Mot de passe",
                  style: ThemeQuinca.corpsTexte.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                PinInput(controller: _nouveauController, onComplet: (_) {}),
                const SizedBox(height: 20),
                Text(
                  "Confirmation",
                  style: ThemeQuinca.corpsTexte.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                PinInput(
                  controller: _confirmationController,
                  onComplet: (_) => _valider(),
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _erreur!,
                    style: const TextStyle(
                      color: ThemeQuinca.rupture,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                ListenableBuilder(
                  listenable: widget.authHook,
                  builder: (context, _) {
                    return BtnPrincipal(
                      texte: "Enregistrer",
                      onPressed: _valider,
                      isLoading: widget.authHook.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
