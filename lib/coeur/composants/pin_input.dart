// lib/coeur/composants/pin_input.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PinInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onComplet;

  const PinInput({
    super.key,
    required this.controller,
    required this.onComplet,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> {
  final FocusNode _focusNode = FocusNode();
  final int _longueurMax = 6;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          // 1. Champ caché qui intercepte le clavier numérique natif
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 1,
              width: 1,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: _longueurMax,
                onChanged: (valeur) {
                  setState(() {});
                  if (valeur.length == _longueurMax) {
                    widget.onComplet(valeur);
                  }
                },
              ),
            ),
          ),
          
          // 2. Les 6 cases calquées sur ton prototype HTML
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_longueurMax, (index) {
              String caractere = "";
              if (widget.controller.text.length > index) {
                caractere = widget.controller.text[index];
              }

              bool estSelectionne = widget.controller.text.length == index && _focusNode.hasFocus;

              return Container(
                width: 48,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Fond bleuté discret de ta maquette
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: estSelectionne 
                        ? const Color(0xFFFD7E14) // Deep-Orange au focus
                        : const Color(0xFF1A3B8B).withValues(alpha: 0.2), // Blue-Pro discret par défaut
                    width: estSelectionne ? 2 : 1,
                  ),
                ),
                child: Text(
                  caractere.isNotEmpty ? "•" : "", // Masquage type Mobile Money
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A3B8B), // Blue-Pro pour le point
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}