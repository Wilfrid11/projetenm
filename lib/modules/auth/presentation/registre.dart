import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../logique/hook.dart';

class RegistrePage extends StatefulWidget {
  final HookAuth authHook;
  const RegistrePage({super.key, required this.authHook});

  @override
  State<RegistrePage> createState() => _RegistrePageState();
}

class _RegistrePageState extends State<RegistrePage> {
  // On utilise une liste de clés pour valider chaque étape indépendamment
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final _pageController = PageController();
  int _currentStep = 0;

  // Etape 1 : Boutique
  final _boutiqueController = TextEditingController();
  final _adresseController = TextEditingController();
  final _villeController = TextEditingController();
  final _telBoutiqueController = TextEditingController();

  // Etape 2 : Admin
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telController.dispose();
    _boutiqueController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _telBoutiqueController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // On ne passe à la suite que si le formulaire de l'étape actuelle est valide
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _procederALinscription() async {
    // Validation finale de l'étape de confirmation
    if (_formKeys[_currentStep].currentState!.validate()) {
      final succes = await widget.authHook.sinscrire(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telController.text.trim(),
        boutique: _boutiqueController.text.trim(),
        adresse: _adresseController.text.trim(),
        ville: _villeController.text.trim(),
        telBoutique: _telBoutiqueController.text.trim(),
        pin: _pinController.text.trim(),
      );

      if (succes && mounted) {
        Navigator.pushReplacementNamed(context, '/role');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.authHook.errorMessage ?? "Erreur d'inscription")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        title: Text("Création de compte", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        backgroundColor: ThemeQuinca.bleuPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Form(key: _formKeys[0], child: _buildStepEtablissement()),
          Form(key: _formKeys[1], child: _buildStepAdmin()),
          Form(key: _formKeys[2], child: _buildStepValidation()),
        ],
      ),
    );
  }

  Widget _buildStepEtablissement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Votre Quincaillerie", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildField("Nom de l'établissement", _boutiqueController, Icons.store_outlined),
          _buildField("Adresse complète", _adresseController, Icons.location_on_outlined),
          Row(
            children: [
              Expanded(child: _buildField("Ville", _villeController, Icons.map_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildField("Tél. Boutique", _telBoutiqueController, Icons.phone_callback, keyboard: TextInputType.phone)),
            ],
          ),
          const SizedBox(height: 30),
          _btnAction("Suivant", _nextStep),
        ],
      ),
    );
  }

  Widget _buildStepAdmin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Compte Administrateur", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildField("Nom", _nomController, Icons.person_outline),
          _buildField("Prénom", _prenomController, Icons.badge_outlined),
          _buildField("Téléphone Personnel", _telController, Icons.phone_android, keyboard: TextInputType.phone),
          _buildField("Code PIN (6 chiffres)", _pinController, Icons.lock_outline, keyboard: TextInputType.number, obscure: true),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: _prevStep, child: const Text("Retour"))),
              const SizedBox(width: 12),
              Expanded(child: _btnAction("Suivant", _nextStep)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepValidation() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user_outlined, size: 80, color: ThemeQuinca.bleuPrincipal),
          const SizedBox(height: 24),
          Text("Offre de bienvenue", style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            "En créant votre compte aujourd'hui, vous profitez de 14 jours d'essai gratuit sur le forfait Pro.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: ThemeQuinca.texteSecondaire),
          ),
          const SizedBox(height: 40),
          ListenableBuilder(
            listenable: widget.authHook,
            builder: (context, child) {
              return SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.authHook.isLoading ? null : _procederALinscription,
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeQuinca.bleuPrincipal),
                  child: widget.authHook.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirmer la création", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
          TextButton(onPressed: _prevStep, child: const Text("Modifier mes infos")),
        ],
      ),
    );
  }

  Widget _btnAction(String label, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeQuinca.bleuPrincipal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboard = TextInputType.text, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: _inputDecoration(label, icon),
        validator: (v) => (v == null || v.isEmpty) ? "Champ obligatoire" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: ThemeQuinca.texteSecondaire, fontSize: 14),
      prefixIcon: Icon(icon, color: ThemeQuinca.bleuPrincipal),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeQuinca.bordure),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeQuinca.bordure),
      ),
    );
  }
}