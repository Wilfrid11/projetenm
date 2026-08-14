import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationApp {
  final String id;
  final String boutiqueId;
  final String titre;
  final String message;
  final String type;
  final bool lu;
  final String createdBy;
  final String createdByNom;
  final String destinataireRole;
  final DateTime? createdAt;

  const NotificationApp({
    required this.id,
    required this.boutiqueId,
    required this.titre,
    required this.message,
    required this.type,
    required this.lu,
    required this.createdBy,
    required this.createdByNom,
    required this.destinataireRole,
    required this.createdAt,
  });

  bool visiblePourRole(String role) {
    return destinataireRole == 'tous' || destinataireRole == role;
  }

  Map<String, dynamic> toMap() {
    return {
      'boutiqueId': boutiqueId,
      'titre': titre,
      'message': message,
      'type': type,
      'lu': lu,
      'createdBy': createdBy,
      'createdByNom': createdByNom,
      'destinataireRole': destinataireRole,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory NotificationApp.fromMap(String id, Map<String, dynamic> map) {
    return NotificationApp(
      id: id,
      boutiqueId: map['boutiqueId'] as String? ?? '',
      titre: map['titre'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'systeme',
      lu: map['lu'] as bool? ?? false,
      createdBy: map['createdBy'] as String? ?? '',
      createdByNom: map['createdByNom'] as String? ?? '',
      destinataireRole: map['destinataireRole'] as String? ?? 'tous',
      createdAt: _dateDepuisFirestore(map['createdAt']),
    );
  }
}

DateTime? _dateDepuisFirestore(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
