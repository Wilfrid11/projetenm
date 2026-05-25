// lib/coeur/theme/theme_quinca.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeQuinca {
  // Charte graphique de ton prototype
  static const Color bleuPro = Color(0xFF1E3A8A);       
  static const Color orangeChantier = Color(0xFFF97316); 
  static const Color grisFond = Color(0xFFF8FAFC);       
  static const Color texteSombre = Color(0xFF1E293B);

  static ThemeData get configurationTheme {
    return ThemeData(
      primaryColor: bleuPro,
      scaffoldBackgroundColor: grisFond,
      
      // Application globale de la police Google Poppins
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        bodyLarge: GoogleFonts.poppins(color: texteSombre),
        bodyMedium: GoogleFonts.poppins(color: texteSombre),
      ),

      // Style des barres de navigation du haut
      appBarTheme: AppBarTheme(
        backgroundColor: bleuPro,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Style par défaut des boutons (Orange Chantier)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangeChantier,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}