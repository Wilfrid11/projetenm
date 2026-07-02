class ContexteQuincaillerie {
  final String boutiqueId;

  const ContexteQuincaillerie(this.boutiqueId);

  bool autorise(String autreBoutiqueId) => boutiqueId == autreBoutiqueId;

  void verifier(String autreBoutiqueId) {
    if (!autorise(autreBoutiqueId)) {
      throw StateError(
        'Acces refuse: cette donnee appartient a une autre quincaillerie.',
      );
    }
  }
}
