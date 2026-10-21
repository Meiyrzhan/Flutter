import 'package:flutter/material.dart';

// The one seed colour of the app; every other colour comes from the
// ColorScheme generated from it.
const Color _seed = Color(0xFF3F51B5);

ThemeData buildTheme(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
  );
}
