import 'package:flutter/material.dart';

import 'router.dart';
import 'routes.dart';
import 'screens/shell.dart';
import 'theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Lives above MaterialApp so the theme can change from the profile tab.
  ThemeMode _themeMode = ThemeMode.system;

  void _changeThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Nights',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: _themeMode,
      initialRoute: Routes.shell,
      routes: {
        Routes.shell: (context) => Shell(
              themeMode: _themeMode,
              onThemeModeChanged: _changeThemeMode,
            ),
      },
      onGenerateRoute: generateRoute,
      onUnknownRoute: unknownRoute,
    );
  }
}
