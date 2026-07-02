String nettoyerTelephone(String telephone) {
  return telephone.replaceAll(RegExp(r'\D'), '');
}

String telephoneLocalDepuisSaisie(String telephone) {
  final chiffres = nettoyerTelephone(telephone);

  if (chiffres.startsWith('229')) {
    return chiffres.substring(3);
  }

  return chiffres;
}

bool telephoneBeninValide(String telephone) {
  final local = telephoneLocalDepuisSaisie(telephone);
  return RegExp(r'^01\d{8}$').hasMatch(local);
}

String normaliserTelephoneBenin(String telephone) {
  final local = telephoneLocalDepuisSaisie(telephone);
  return '+229$local';
}

String emailTechniqueDepuisTelephone(String telephone) {
  final local = telephoneLocalDepuisSaisie(telephone);
  return '$local@quincapro.local';
}
