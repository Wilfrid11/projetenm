// lib/modules/auth/data/user.dart

class User {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String role;
  final String
      boutiqueId; // ID unique de la quincaillerie (ex: UUID ou PK backend)
  final String nomBoutique; // Ajouté pour l'ancrage commercial
  final String adresse;
  final String ville;
  final String telephoneBoutique;
  final bool actif;
  final bool mustChangePassword;

  const User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    required this.boutiqueId,
    required this.nomBoutique,
    required this.adresse,
    required this.ville,
    required this.telephoneBoutique,
    bool? isFirstLogin,
    bool? mustChangePassword,
    this.actif = true,
  }) : mustChangePassword = mustChangePassword ?? isFirstLogin ?? false;

  // Helpers pour le contrôle des rôles
  bool get isAdmin => role == 'admin';
  bool get isGerant => role == 'gerant';
  bool get isFirstLogin => mustChangePassword;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'role': role,
      'boutiqueId': boutiqueId,
      'nomBoutique': nomBoutique,
      'adresse': adresse,
      'ville': ville,
      'telephoneBoutique': telephoneBoutique,
      'actif': actif,
      'mustChangePassword': mustChangePassword,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '',
      nom: map['nom'] as String? ?? '',
      prenom: map['prenom'] as String? ?? '',
      telephone: map['telephone'] as String? ?? '',
      role: map['role'] as String? ?? 'gerant',
      boutiqueId: map['boutiqueId'] as String? ?? '',
      nomBoutique: map['nomBoutique'] as String? ?? '',
      adresse: map['adresse'] as String? ?? '',
      ville: map['ville'] as String? ?? '',
      telephoneBoutique: map['telephoneBoutique'] as String? ?? '',
      actif: map['actif'] as bool? ?? true,
      mustChangePassword: (map['mustChangePassword'] as bool?) ??
          (map['isFirstLogin'] as bool?) ??
          false,
    );
  }
}
