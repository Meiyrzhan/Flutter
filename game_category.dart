import 'package:flutter/material.dart';

enum GameCategory {
  strategy('Strategy', Icons.psychology),
  party('Party', Icons.celebration),
  coop('Co-op', Icons.groups),
  cards('Card games', Icons.style),
  roleplay('Role-play', Icons.theater_comedy);

  const GameCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Background colour of the category: a colorScheme role, never a literal.
  Color colorOf(ColorScheme scheme) => switch (this) {
        GameCategory.strategy => scheme.primary,
        GameCategory.party => scheme.tertiary,
        GameCategory.coop => scheme.secondary,
        GameCategory.cards => scheme.primaryContainer,
        GameCategory.roleplay => scheme.tertiaryContainer,
      };

  /// Readable foreground for [colorOf].
  Color onColorOf(ColorScheme scheme) => switch (this) {
        GameCategory.strategy => scheme.onPrimary,
        GameCategory.party => scheme.onTertiary,
        GameCategory.coop => scheme.onSecondary,
        GameCategory.cards => scheme.onPrimaryContainer,
        GameCategory.roleplay => scheme.onTertiaryContainer,
      };
}
