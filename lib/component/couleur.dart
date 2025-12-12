import 'dart:ui';
import 'package:flutter/material.dart';

LinearGradient monDegrade({
  Alignment begin = Alignment.topLeft,
  Alignment end = Alignment.bottomRight,
}) {
  return LinearGradient(
    begin: begin,
    end: end,
    colors: const [
      Color(0xFF6A11CB),
      Color(0xFF0D47A1),
    ],
  );
}

class Couleur {
  // Palette de couleurs de l'application D'Sert

  /// Couleur principale pour les éléments d'action (boutons, app bars).
  static const Color principale = Color(0xFF1E3A8A);

  /// Couleur secondaire pour les accents et les liens.
  static const Color secondaire = Color(0xFF3B82F6);

  /// Couleur de fond pour la plupart des écrans.
  static const Color fond = Color(0xFFF8FAFC);

  /// Couleur de surface pour les cartes (Card) et les dialogues.
  static const Color surface = Color(0xFFFFFFFF);

  /// Couleur pour le texte principal (titres, paragraphes).
  static const Color textePrincipal = Color(0xFF1E293B);

  /// Couleur pour le texte secondaire (labels, descriptions).
  static const Color texteSecondaire = Color(0xFF64748B);

  /// Couleur pour indiquer le succès ou une validation.
  static const Color succes = Color(0xFF16A34A);

  /// Couleur pour les avertissements ou les statuts "en attente".
  static const Color avertissement = Color(0xFFF59E0B);

  /// Couleur pour les erreurs ou les actions dangereuses.
  static const Color erreur = Color(0xFFDC2626);
}
