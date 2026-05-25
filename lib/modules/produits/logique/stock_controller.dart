import 'package:flutter/material.dart';
import '../data/produit.dart';

class StockController extends ChangeNotifier {
  // Notre "Base de données" locale
  final List<Produit> _produitsDuMagasin = [
    Produit(nom: "Ciment CPJ 45", reference: "CIM-001", categorie: "Construction", quantite: 50, prixAchat: 4500, prixVente: 5000, seuilAlerte: 10),
    Produit(nom: "Fer à béton 12mm", reference: "FER-012", categorie: "Quincaillerie", quantite: 5, prixAchat: 3000, prixVente: 3500, seuilAlerte: 15),
  ];

  List<Produit> get produits => _produitsDuMagasin;

  // Historique des arrivages
  final List<Map<String, dynamic>> historique = [];

  // ACTION 1 : Créer dans le catalogue
  void creerFicheCatalogue(Produit p) {
    _produitsDuMagasin.add(p);
    notifyListeners(); // Actualise l'application partout
  }

  // ACTION 2 : Arrivage (Entrée de stock)
  void enregistrerArrivage(String ref, int qte, String auteur) {
    final p = _produitsDuMagasin.firstWhere((prod) => prod.reference == ref);
    p.quantite += qte;
    
    historique.insert(0, {
      'produit': p.nom,
      'quantite': qte,
      'auteur': auteur,
      'date': DateTime.now().toString().substring(0, 16),
    });
    
    notifyListeners();
  }

  // ACTION 3 : Vente (Sortie de stock)
  void effectuerVente(String ref, int qte) {
    final p = _produitsDuMagasin.firstWhere((prod) => prod.reference == ref);
    if (p.quantite >= qte) {
      p.quantite -= qte;
      notifyListeners();
    }
  }
}