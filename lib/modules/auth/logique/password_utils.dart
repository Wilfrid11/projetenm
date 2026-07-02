import 'dart:math';

bool motDePasseSixChiffresValide(String value) {
  return RegExp(r'^\d{6}$').hasMatch(value);
}

String genererMotDePasseTemporaire() {
  final random = Random.secure();
  return List.generate(6, (_) => random.nextInt(10)).join();
}
