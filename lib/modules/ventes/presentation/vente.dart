// lib/modules/ventes/presentation/vente.dart

import 'package:flutter/material.dart';
import '../../../coeur/theme/theme_quinca.dart';
import '../../../coeur/composants/btn_principal.dart';
import '../logique/vente_controller.dart';
import '../../produits/data/produit.dart';

class VentePage extends StatelessWidget {
  final VenteController venteController;

  const VentePage({super.key, required this.venteController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeQuinca.fondGris,
      appBar: AppBar(
        backgroundColor: ThemeQuinca.bleuPrincipal,
        elevation: 0,
        title: Text(
          "Encaissement",
          style: ThemeQuinca.titrePrincipal.copyWith(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: venteController,
        builder: (context, _) {
          if (venteController.panier.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: venteController.panier.length,
                  itemBuilder: (context, index) {
                    final item = venteController.panier[index];
                    return _buildPanierItem(context, item.produit, item.quantiteChoisie);
                  },
                ),
              ),
              _buildResumePaiement(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: ThemeQuinca.texteSecondaire.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text("Le panier est vide", style: ThemeQuinca.titrePrincipal),
          const SizedBox(height: 8),
          Text("Ajoutez des produits depuis le catalogue", style: ThemeQuinca.corpsTexte),
        ],
      ),
    );
  }

  Widget _buildPanierItem(BuildContext context, Produit p, int qte) {
    return GestureDetector(
      onLongPress: () => _saisirQuantiteManuelle(context, p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeQuinca.bordure),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nom, style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 15)),
                  Text("${p.prixVente.toInt()} FCFA / unité", style: ThemeQuinca.corpsTexte.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Row(
              children: [
                _buildIconButton(Icons.remove, () => venteController.diminuerOuRetirer(p)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("$qte", style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16)),
                ),
                _buildIconButton(Icons.add, () => venteController.ajouterAuPanier(p)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icone, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ThemeQuinca.fondGris,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icone, size: 18, color: ThemeQuinca.bleuPrincipal),
      ),
    );
  }

  Widget _buildResumePaiement(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total à payer", style: ThemeQuinca.corpsTexte.copyWith(fontWeight: FontWeight.bold)),
              Text(
                "${venteController.montantTotalGlobal.toInt()} FCFA",
                style: ThemeQuinca.titrePrincipal.copyWith(color: ThemeQuinca.bleuPrincipal, fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BtnPrincipal(
            texte: "Finaliser la vente",
            onPressed: () => _choisirModePaiement(context),
          ),
        ],
      ),
    );
  }

  void _saisirQuantiteManuelle(BuildContext context, Produit p) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quantité pour ${p.nom}", style: ThemeQuinca.titrePrincipal.copyWith(fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: ThemeQuinca.inputDecoration(label: "Saisir la quantité", icone: Icons.edit_note),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              int? val = int.tryParse(ctrl.text);
              if (val != null) {
                final succes = venteController.definirQuantite(p, val);
                if (!succes) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stock insuffisant !")));
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: ThemeQuinca.bleuPrincipal),
            child: const Text("Confirmer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _choisirModePaiement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mode de règlement", style: ThemeQuinca.titrePrincipal),
            const SizedBox(height: 8),
            Text("Sélectionnez le moyen de paiement utilisé par le client.", style: ThemeQuinca.corpsTexte),
            const SizedBox(height: 24),
            _buildModeOption(context, "Espèces", Icons.payments_outlined),
            _buildModeOption(context, "Momo (MTN)", Icons.phone_android),
            _buildModeOption(context, "Moov Money", Icons.phone_android),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(BuildContext context, String titre, IconData icone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeQuinca.bordure),
      ),
      child: ListTile(
        leading: Icon(icone, color: ThemeQuinca.bleuPrincipal),
        title: Text(titre, style: ThemeQuinca.corpsTexte.copyWith(fontWeight: FontWeight.bold, color: ThemeQuinca.texteFonce)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {
          final succes = venteController.validerLaVente(titre);
          Navigator.pop(context); // Ferme le BottomSheet
          if (succes) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: ThemeQuinca.succes,
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 10),
                    Text("Vente enregistrée avec succès ($titre)"),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}