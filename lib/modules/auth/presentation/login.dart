import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../coeur/composants/btn_principal.dart';
import '../../../coeur/composants/pin_input.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../dashbord/presentation/role.dart';
import '../../produits/logique/stock_controller.dart';
import '../../ventes/logique/vente_controller.dart';
import '../data/user.dart';
import '../logique/hook.dart';
import '../logique/password_utils.dart';
import '../logique/telephone_utils.dart';
import '../logique/user_controller.dart';
import 'changement_mot_de_passe.dart';
import 'registre.dart';

class Login extends StatefulWidget {
  final StockController stockController;

  const Login({super.key, required this.stockController});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final UserController _userController = UserController();
  final HookAuth _authHook = HookAuth();
  bool _enChargement = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate() ||
        !motDePasseSixChiffresValide(_pinController.text)) {
      return;
    }

    setState(() => _enChargement = true);

    final telephoneSaisi = normaliserTelephoneBenin(_phoneController.text);
    final motDePasseSaisi = _pinController.text.trim();
    final succes = await _authHook.seConnecter(
      telephoneSaisi,
      motDePasseSaisi,
    );

    if (!mounted) return;

    if (!succes || _authHook.currentUser == null) {
      setState(() => _enChargement = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authHook.errorMessage ??
                "Numero de telephone ou mot de passe incorrect",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final User utilisateurAConnecter = _authHook.currentUser!;

    widget.stockController
        .initialiserBoutique(utilisateurAConnecter.boutiqueId);
    setState(() => _enChargement = false);

    final venteController = VenteController(
      stockController: widget.stockController,
      boutiqueId: utilisateurAConnecter.boutiqueId,
    );

    if (utilisateurAConnecter.mustChangePassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangementMotDePassePage(
            authHook: _authHook,
            user: utilisateurAConnecter,
            stockController: widget.stockController,
            venteController: venteController,
            userController: _userController,
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RolePage(
          user: utilisateurAConnecter,
          stockController: widget.stockController,
          venteController: venteController,
          userController: _userController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ThemeQuinca.bleuPrincipal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "QuincaPro",
                style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 32),
              ),
              Text(
                "Gestion de quincaillerie",
                style: ThemeQuinca.corpsTexte.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 40),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ThemeQuinca.bordure),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Connexion a votre espace",
                        style: ThemeQuinca.titrePrincipal,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Numero de telephone",
                        style: ThemeQuinca.corpsTexte.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                        ),
                        validator: (value) {
                          if (value == null ||
                              !telephoneBeninValide(value.trim())) {
                            return "Numero invalide (ex: 0197000000)";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: ThemeQuinca.bordure),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone_android_outlined,
                                  size: 20,
                                  color: ThemeQuinca.texteSecondaire,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "+229",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeQuinca.bleuPrincipal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hintText: "0197000000",
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: ThemeQuinca.bordure,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: ThemeQuinca.bordure,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: ThemeQuinca.alerte,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Mot de passe (6 chiffres)",
                        style: ThemeQuinca.corpsTexte.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PinInput(
                        controller: _pinController,
                        onComplet: (_) => _soumettre(),
                      ),
                      const SizedBox(height: 32),
                      BtnPrincipal(
                        texte: "Se connecter",
                        onPressed: _soumettre,
                        isLoading: _enChargement,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Nouveau sur QuincaPro ? ",
                            style: ThemeQuinca.corpsTexte,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegistrePage(
                                    authHook: _authHook,
                                    stockController: widget.stockController,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Creer un espace",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: ThemeQuinca.alerte,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
