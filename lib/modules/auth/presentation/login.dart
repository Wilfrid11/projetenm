// lib/modules/auth/presentation/login.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/composants/pin_input.dart';
import '../../dashbord/presentation/admin.dart';
import '../../dashbord/presentation/gerant.dart';
import '../data/mock.dart';
import '../data/user.dart';
import '../../dashbord/logique/dashboard_hook.dart';
import '../../dashbord/logique/gerant_hook.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _enChargement = false;

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

    // 2. On vérifie si ce numéro et ce PIN existent dans ton fichier mock.dart
    if (mockCredentials.containsKey(telephoneSaisi) && mockCredentials[telephoneSaisi] == pinSaisi) {
      
      // On récupère l'utilisateur correspondant (Kofi ou Amos)
      User utilisateurAConnecter = mockUsers[telephoneSaisi]!;

      // 3. On regarde son rôle pour savoir où l'envoyer
      if (utilisateurAConnecter.role == "admin") {
        
        // On connecte l'admin au Hook (ça libère son nom pour le profil)
        final adminHook = HookDashboard();
        adminHook.definirUtilisateurConnecte(utilisateurAConnecter);

        setState(() => _enChargement = false);

        // On ouvre l'écran de l'Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );

      } else if (utilisateurAConnecter.role == "gerant") {
        
        // On connecte le gérant au Hook (ça libère son nom pour le profil)
        final gerantHook = HookGerant();
        gerantHook.definirUtilisateurConnecte(utilisateurAConnecter);

        setState(() => _enChargement = false);

        // On ouvre l'écran du Gérant
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GerantDashboard()),
        );
      }
      
    } else {
      // Si le numéro ou le PIN est faux, on arrête le chargement et on affiche une erreur
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
      backgroundColor: const Color(0xFFF8FAFC), // Fond gris chirurgical
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. En-tête (Logo et Titre du logiciel)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3B8B), // Blue-Pro
                  borderRadius: BorderRadius.circular(20),
                ),
                
              ),
              const SizedBox(height: 16),
              Text(
                "QuincaPro",
                style: GoogleFonts.urbanist(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                "Gestion de quincaillerie",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 40),

              // 2. Carte du Formulaire
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Connexion à votre espace",
                        style: GoogleFonts.urbanist(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Champ Numéro de téléphone
                      Text(
                        "Numéro de téléphone",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_android_outlined, size: 20, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  "+229",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A3B8B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hintText: "97 00 00 00",
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFFD7E14), width: 2), // Deep-Orange
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Champ Code PIN
                      Text(
                        "Code PIN (6 chiffres)",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PinInput(
                        controller: _pinController,
                        onComplet: (code) => _soumettre(),
                      ),
                      const SizedBox(height: 32),

                      // Bouton Se connecter
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _enChargement ? null : _soumettre,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3B8B), // Blue-Pro
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _enChargement
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  "Se connecter",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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