// lib/modules/auth/data/mock.dart

import 'user.dart';

const Map<String, String> mockCredentials = {
  "+2290197000000": "111111", // Kofi MENSAH
  "+2290196000000": "123456", // Amos AGBOSSOU
};

const Map<String, User> mockUsers = {
  "+2290197000000": User(
    id: "USR-001",
    nom: "MENSAH",
    prenom: "Kofi",
    telephone: "+2290197000000",
    role: "admin",
    boutiqueId: "BTQ-001", // Ajout du boutiqueId
    nomBoutique: "Quincaillerie Centrale Pro",
    telephoneBoutique: "+22921300000", // Numéro de la boutique
    adresse: "Cotonou, Bénin", // Ajout d'une adresse par défaut
    ville: "Cotonou",
    mustChangePassword: false,
  ),
  "+2290196000000": User(
    id: "USR-002",
    nom: "AGBOSSOU",
    prenom: "Amos",
    telephone: "+2290196000000",
    role: "gerant",
    boutiqueId: "BTQ-001", // Lié à la même boutique que Kofi pour l'exemple
    nomBoutique: "Quincaillerie Étoile de Parakou", // Lié à la boutique gérée
    telephoneBoutique: "+22923600000", // Numéro de la boutique
    adresse: "Parakou, Bénin", // Ajout d'une adresse par défaut
    ville: "Parakou",
    mustChangePassword: true,
  ),
};
