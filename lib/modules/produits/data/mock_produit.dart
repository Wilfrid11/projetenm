// // lib/modules/dashboard/data/mock_produits.dart

// import 'produit.dart';

// // Notre fausse liste de produits pour alimenter la vitrine passive
// List<Produit> mockListeProduits = [
//   Produit(
//     reference: "REF-CIM-01",
//     nom: "Ciment Bouclier 32.5",
//     categorie: "Gros Œuvre",
//     prixAchat: 3800,
//     prixVente: 4500,
//     quantite: 0, // 0 en stock -> Déclenchera le ROUGE automatiquement
//     seuilAlerte: 10,
//   ),
//    Produit(
//     reference: "REF-FER-12",
//     nom: "Fer 12mm — 6m",
//     categorie: "Gros Œuvre",
//     prixAchat: 5100,
//     prixVente: 5900,
//     quantite: 8, // 8 <= 15 (Seuil) -> Déclenchera l'ORANGE automatiquement
//     seuilAlerte: 15,
//   ),
//    Produit(
//     reference: "REF-PLM-03",
//     nom: "Tuyau PVC Ø100",
//     categorie: "Plomberie",
//     prixAchat: 1200,
//     prixVente: 1800,
//     quantite: 120, // 120 > 20 -> Déclenchera le VERT automatiquement
//     seuilAlerte: 20,
//   ),
// ];

// // Notre faux journal de bord pour l'Option 3 du Drawer
// List<Map<String, dynamic>> mockHistoriqueEntrees = [
//   {
//     "date": "25/05/2026",
//     "produit": "Ciment Bouclier 32.5",
//     "quantite": 200,
//     "auteur": "Kofi MENSAH (Admin)"
//   },
//   {
//     "date": "24/05/2026",
//     "produit": "Tuyau PVC Ø100",
//     "quantite": 50,
//     "auteur": "Amos AGBOSSOU (Gérant)"
//   },
// ];