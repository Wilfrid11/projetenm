import 'package:flutter/material.dart';

import '../theme/theme_quinca.dart';

class BtnPrincipal extends StatelessWidget {
  final String texte;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color couleur;

  const BtnPrincipal({
    super.key,
    required this.texte,
    required this.onPressed,
    this.isLoading = false,
    this.couleur = ThemeQuinca.bleuPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: couleur,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                texte,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
