// lib/coeur/composants/champ_telephone.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChampTelephone extends StatelessWidget {
  final TextEditingController controller;

  const ChampTelephone({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Color(0xFF64748B), size: 18),
          const SizedBox(width: 8),
          Text(
            "+229",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E3A8A),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1E293B)),
              decoration: const InputDecoration(
                hintText: "97 00 00 00",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}