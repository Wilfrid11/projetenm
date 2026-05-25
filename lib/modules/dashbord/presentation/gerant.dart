// lib/modules/dashboard/presentation/gerant.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../composants/alerte.dart';
import '../logique/gerant_hook.dart';
import '../data/mock_dashboard.dart'; // Import du Mock partagé (alertes et stats)
import '../../auth/data/user.dart'; // Ton vrai modèle User

class GerantDashboard extends StatefulWidget {
  const GerantDashboard({super.key});

  @override
  State<GerantDashboard> createState() => _GerantDashboardState();
}

class _GerantDashboardState extends State<GerantDashboard> {
  int _currentIndex = 0;
  final HookGerant _gerantHook = HookGerant();

  @override
  Widget build(BuildContext context) {
    final stats = _gerantHook.stats;
    final User user = _gerantHook.utilisateurConnecte;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête bleu personnalisé et 100% dynamique
              _buildHeader(user),
              const SizedBox(height: 24),

              // Les 2 cartes de statistiques du haut (Ventes du jour / Articles critiques)
              _buildZoneStats(stats),
              const SizedBox(height: 24),

              // Section Actions Flash (Grands boutons blancs)
              Text(
                "Actions flash",
                style: GoogleFonts.urbanist(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              
              _actionFlashBtn("Nouvelle vente (panier)", Icons.add_shopping_cart_rounded, const Color(0xFFF97316), () {
                // Test dynamique : incrémente le compteur en haut au clic
                setState(() => _gerantHook.incrementerVentes());
              }),
              _actionFlashBtn("Ajouter / Réceptionner produit", Icons.unarchive_rounded, const Color(0xFFEA580C), () {
                // TODO: Développer l'ouverture du formulaire d'ajout/réception après
                print("Clic sur Ajouter / Réceptionner produit");
              }),
              _actionFlashBtn("Bon de sortie de stock", Icons.local_shipping_outlined, const Color(0xFFF97316), () {
                // TODO: Gérer la création de bon de sortie après
                print("Clic sur Bon de sortie de stock");
              }),
              const SizedBox(height: 24),

              // Section Alertes critiques de stock
              Text(
                "Alertes critiques de stock",
                style: GoogleFonts.urbanist(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              // DYNAMIQUE : Boucle sur le même mock d'alertes que l'admin
              ...mockAlertesStock.map((alerte) {
                return AlerteCard(
                  nom: alerte['nom'],
                  statut: alerte['statut'],
                  label: alerte['label'],
                  couleur: alerte['couleur'],
                  icone: alerte['icone'],
                );
              }).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // En-tête construit uniquement sur les propriétés de ton modèle User
  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Bleu gérant
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VRAI CHAMP : nomComplet
                  Text(
                    user.nomComplet, 
                    style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24, 
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // VRAI CHAMP : role
                    child: Text(
                      user.role.toUpperCase(), 
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              // VRAI CHAMP : nomBoutique (Affiche la boutique assignée à Amos)
              Text(
                user.nomBoutique, 
                style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneStats(dynamic stats) {
    return Row(
      children: [
        Expanded(child: _statCard("Ventes du jour", "${stats.nombreVentesJour}", Icons.receipt_long_rounded, const Color(0xFF10B981))),
        const SizedBox(width: 16),
        Expanded(child: _statCard("Articles critiques", "${stats.articlesCritiques}", Icons.warning_amber_rounded, const Color(0xFFF59E0B))),
      ],
    );
  }

  Widget _statCard(String titre, String valeur, IconData icone, Color couleur) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur, size: 24),
          const SizedBox(height: 12),
          Text(valeur, style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.bold, color: couleur)),
          const SizedBox(height: 4),
          Text(titre, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _actionFlashBtn(String libelle, IconData icone, Color couleurIcone, VoidCallback auClic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: auClic,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(icone, color: couleurIcone, size: 28),
              const SizedBox(width: 16),
              Text(
                libelle,
                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E3A8A),
      unselectedItemColor: const Color(0xFF64748B),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Accueil"),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Produits"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: "Ventes"),
        BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "Historique"),
      ],
    );
  }
}