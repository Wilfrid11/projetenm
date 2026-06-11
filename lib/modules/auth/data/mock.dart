// lib/modules/auth/data/mock.dart

import 'user.dart';

const Map<String, String> mockCredentials = {
  "+22997000000": "111111", // Kofi MENSAH
  "+22996000000": "123456", // Amos AGBOSSOU (PIN Temporaire)
};

const Map<String, User> mockUsers = {
  "+22997000000": User(
    id: "USR-001",
    nom: "MENSAH",
    prenom: "Kofi",
    telephone: "+22997000000",
    role: "admin",
    nomBoutique: "Quincaillerie Centrale Pro",
    telephoneBoutique: "+22921300000", // Numéro de la boutique
    adresse: "Cotonou, Bénin", // Ajout d'une adresse par défaut
    ville: "Cotonou",
    isFirstLogin: false,
  ),
  "+22996000000": User(
    id: "USR-002",
    nom: "AGBOSSOU",
    prenom: "Amos",
    telephone: "+22996000000",
    role: "gerant",
    nomBoutique: "Quincaillerie Étoile de Parakou", // Lié à la boutique gérée
    telephoneBoutique: "+22923600000", // Numéro de la boutique
    adresse: "Parakou, Bénin", // Ajout d'une adresse par défaut
    ville: "Parakou",
    isFirstLogin: true,
  ),
};