// lib/modules/auth/presentation/reset.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coeur/composants/pin_input.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final _formKey = GlobalKey<FormState>();
  final _nouveauPinController = TextEditingController();
  final _confirmerPinController = TextEditingController();
  bool _enChargement = false;
  String? _erreurTexte;

  @override
  void dispose() {
    _nouveauPinController.dispose();
    _confirmerPinController.dispose();
    super.dispose();
  }

  void _enregistrerNouveauPin() {
    setState(() => _erreurTexte = null);

    if (_nouveauPinController.text.length != 6 || _confirmerPinController.text.length != 6) {
      setState(() => _erreurTexte = "Veuillez remplir intégralement les deux champs.");
      return;
    }

    if (_nouveauPinController.text != _confirmerPinController.text) {
      setState(() => _erreurTexte = "Les deux codes PIN ne correspondent pas.");
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _enChargement = true);
      
      // Ici sera branchée la logique de mise à jour (Mock ou API Laravel)
      print("Nouveau PIN configuré avec succès !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
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
                  // Icone d'alerte sécurité
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: Color(0xFFFD7E14), size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "Sécurité requise",
                        style: GoogleFonts.urbanist(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Message d'alerte explicatif du cahier des charges
                  Text(
                    "Pour des raisons de sécurité, veuillez personnaliser votre code PIN à 6 chiffres avant de continuer.",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Bloc Nouveau PIN
                  Text(
                    "Nouveau Code PIN",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PinInput(
                    controller: _nouveauPinController,
                    onComplet: (_) {}, // On attend la validation finale par bouton
                  ),
                  const SizedBox(height: 24),

                  // Bloc Confirmer PIN
                  Text(
                    "Confirmer le Code PIN",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PinInput(
                    controller: _confirmerPinController,
                    onComplet: (_) => _enregistrerNouveauPin(), // Soumission au dernier chiffre entré
                  ),
                  
                  // Zone d'affichage d'erreur dynamique
                  if (_erreurTexte != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _erreurTexte!,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Bouton Enregistrer et Continuer
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _enChargement ? null : _enregistrerNouveauPin,
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
                              "Enregistrer et Continuer",
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
        ),
      ),
    );
  }
}