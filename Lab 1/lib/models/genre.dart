import 'package:flutter/material.dart';

/// The book category (R2): an enhanced enum with a label and an icon.
enum Genre {
  fantasy('Fantasy', Icons.auto_stories),
  scifi('Sci-fi', Icons.rocket_launch),
  mystery('Mystery', Icons.search),
  history('History', Icons.account_balance),
  science('Science', Icons.science),
  poetry('Poetry', Icons.edit_note);

  const Genre(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Exhaustive switch expression: adding a value without a colour
  /// does not compile. Returns a colorScheme role, never a literal colour.
  Color color(ColorScheme scheme) => switch (this) {
    Genre.fantasy => scheme.primary,
    Genre.scifi => scheme.secondary,
    Genre.mystery => scheme.tertiary,
    Genre.history => scheme.error,
    Genre.science => scheme.onSecondaryContainer,
    Genre.poetry => scheme.onTertiaryContainer,
  };
}
