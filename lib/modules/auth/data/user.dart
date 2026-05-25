// lib/modules/auth/data/user.dart

class User {
  final String id;
  final String nomComplet; // Remplacé conformément à tes exigences
  final String telephone;
  final String role; 
  final String nomBoutique; // Ajouté pour l'ancrage commercial
  final bool isFirstLogin; 

  const User({
    required this.id,
    required this.nomComplet,
    required this.telephone,
    required this.role,
    required this.nomBoutique,
    required this.isFirstLogin,
  });
}