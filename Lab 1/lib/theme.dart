import 'package:flutter/material.dart';

// R22: the only colour literal in the project. ColorScheme.fromSeed needs a
// seed; every other colour in lib/ comes from the generated colorScheme.
const _seed = Color(0xFF3F6B5E);

ThemeData buildTheme(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    ),
  );
}
