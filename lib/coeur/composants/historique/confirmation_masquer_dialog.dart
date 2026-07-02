import 'package:flutter/material.dart';

Future<bool> confirmerMasquageHistorique(BuildContext context) async {
  final resultat = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Masquer cet element ?"),
      content: const Text(
        "Cette action retire la carte de l'ecran, mais ne supprime pas les donnees et ne modifie pas le stock.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Masquer"),
        ),
      ],
    ),
  );

  return resultat ?? false;
}
