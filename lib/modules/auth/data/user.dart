// lib/modules/auth/data/user.dart

class User {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String role; 
  final String nomBoutique; // Ajouté pour l'ancrage commercial
  final String adresse;
  final String ville;
  final String telephoneBoutique;
  final bool isFirstLogin; 

  const User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    required this.nomBoutique,
    required this.adresse,
    required this.ville,
    required this.telephoneBoutique,
    required this.isFirstLogin,
  });
}