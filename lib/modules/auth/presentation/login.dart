import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/composants/pin_input.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../../coeur/composants/btn_principal.dart';
import '../../dashbord/presentation/role.dart'; // Import de l'aiguilleur
import '../../produits/logique/stock_controller.dart';
import '../../ventes/logique/vente_controller.dart'; // Import indispensable 
import '../data/mock.dart';
import '../data/user.dart';
import 'registre.dart'; 
import 'reset.dart';
import '../logique/user_controller.dart';
import '../logique/hook.dart'; 

class Login extends StatefulWidget {
  // On passe le stockController au Login pour qu'il puisse le donner à la RolePage
  final StockController stockController;

  const Login({super.key, required this.stockController});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _enChargement = false;
  final UserController _userController = UserController(); // Instance persistante

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (_formKey.currentState!.validate() && _pinController.text.length == 6) {
      setState(() => _enChargement = true);

      // 1. On reforme le numéro complet avec l'indicatif du Bénin (+229)
      String telephoneSaisi = "+229${_phoneController.text.trim()}";
      String pinSaisi = _pinController.text.trim();

      // 2. On vérifie si ce numéro et ce PIN existent
      if (mockCredentials.containsKey(telephoneSaisi) &&
          mockCredentials[telephoneSaisi] == pinSaisi) {
        // On récupère l'utilisateur correspondant (Kofi ou Amos)
        User utilisateurAConnecter = mockUsers[telephoneSaisi]!;

        setState(() => _enChargement = false);

        // Initialisation du périmètre boutique pour le stock
        widget.stockController.initialiserBoutique(utilisateurAConnecter.boutiqueId);

        // 3. PLUS DE HOOKS ! On envoie tout le monde sur RolePage.
        // C'est elle qui choisira d'afficher DashboardPage ou GerantPage.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RolePage(
              user: utilisateurAConnecter,
              stockController: widget.stockController,
              venteController: VenteController(
                stockController: widget.stockController,
                boutiqueId: utilisateurAConnecter.boutiqueId,
              ),
              userController: _userController, // Passage du userController
            ),
          ),
        );
      } else {
        // Si le numéro ou le PIN est faux
        setState(() => _enChargement = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Numéro de téléphone ou code PIN incorrect"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              // Logo & Titre
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

              // Carte du Formulaire
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
                        "Connexion à votre espace",
                        style: ThemeQuinca.titrePrincipal,
                      ),
                      const SizedBox(height: 24),

                      // Champ Téléphone
                      Text(
                        "Numéro de téléphone",
                        style: ThemeQuinca.corpsTexte.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                        ),
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
                          hintText: "97 00 00 00",
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: ThemeQuinca.bordure),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: ThemeQuinca.bordure),
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

                      // Champ Code PIN
                      Text(
                        "Code PIN (6 chiffres)",
                        style: ThemeQuinca.corpsTexte.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      PinInput(
                        controller: _pinController,
                        onComplet: (code) => _soumettre(),
                      ),
                      const SizedBox(height: 32),

                      // Bouton Se connecter
                      BtnPrincipal(
                        texte: "Se connecter",
                        onPressed: _soumettre,
                        isLoading: _enChargement,
                      ),
                      const SizedBox(height: 24),

                      // ◄ SEUL AJOUT : Le lien vers l'inscription avec transmission du stockController
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
                                    authHook: HookAuth(), 
                                    stockController: widget.stockController,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Créer un espace",
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
