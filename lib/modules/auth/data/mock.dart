// lib/modules/auth/data/mock.dart

import 'user.dart';

const Map<String, String> mockCredentials = {
  "+22997000000": "111111", // Kofi MENSAH
  "+22996000000": "123456", // Amos AGBOSSOU (PIN Temporaire)
};

const Map<String, User> mockUsers = {
  "+22997000000": User(
    id: "USR-001",
    nomComplet: "Kofi MENSAH",
    telephone: "+22997000000",
    role: "admin",
    nomBoutique: "Quincaillerie Centrale Pro",
    isFirstLogin: false,
  ),
  "+22996000000": User(
    id: "USR-002",
    nomComplet: "Amos AGBOSSOU",
    telephone: "+22996000000",
    role: "gerant",
    nomBoutique: "Quincaillerie Étoile de Parakou", // Lié à la boutique gérée
    isFirstLogin: true,
  ),
};