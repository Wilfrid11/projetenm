// lib/core/composants/filtre.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_quinca.dart';

class Filtre extends StatefulWidget {
  final String categorieInitiale; // Permet de synchroniser l'état avec la page parente
  final Function(String) onRechercheChange;
  final Function(String) onCategorieChange;

  const Filtre({
    super.key,
    this.categorieInitiale = "Tout",
    required this.onRechercheChange,
    required this.onCategorieChange,
  });

  @override
  State<Filtre> createState() => _FiltreState();
}

class _FiltreState extends State<Filtre> {
  late String _categorieSelectionnee;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = ["Tout", "Plomberie", "Électricité", "Gros Œuvre", "Peinture"];

  @override
  void initState() {
    super.initState();
    _categorieSelectionnee = widget.categorieInitiale;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Zone de recherche (Barre bleue)
        Container(
          color: ThemeQuinca.bleuPrincipal,
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: widget.onRechercheChange,
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                hintStyle: GoogleFonts.inter(color: ThemeQuinca.texteSecondaire, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: ThemeQuinca.texteSecondaire),
                // Bouton de nettoyage dynamique (X)
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: ThemeQuinca.texteSecondaire, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          widget.onRechercheChange("");
                          setState(() {}); // Met à jour l'état pour cacher le bouton X
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Liste horizontale des catégories
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final estSelectionne = _categorieSelectionnee == cat;
              return GestureDetector(
                onTap: () {
                  setState(() => _categorieSelectionnee = cat);
                  widget.onCategorieChange(cat);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: estSelectionne ? ThemeQuinca.bleuPrincipal : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: estSelectionne ? ThemeQuinca.bleuPrincipal : ThemeQuinca.bordure,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 13, 
                        fontWeight: estSelectionne ? FontWeight.bold : FontWeight.w500, 
                        color: estSelectionne ? ThemeQuinca.texteInverse : ThemeQuinca.texteSecondaire,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}