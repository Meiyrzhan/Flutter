import 'package:flutter/material.dart';

import 'models/book.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// R25: every route name lives here.
abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// R26: the detail gets the book and the callbacks it may call.
class DetailArgs {
  const DetailArgs({
    required this.book,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onGoToProfile,
  });

  final Book book;
  final String profileName;
  final ValueChanged<Book> onChanged;
  final ValueChanged<String> onDelete;
  final VoidCallback onGoToProfile;
}

/// R26: the form gets a book to edit (or none) and returns a Book via pop.
class FormArgs {
  const FormArgs({this.book});

  final Book? book;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case Routes.detail:
      if (args is DetailArgs) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => DetailScreen(args: args),
        );
      }
    case Routes.form:
      if (args is FormArgs) {
        return MaterialPageRoute<Book>(
          settings: settings,
          builder: (context) => FormScreen(args: args),
        );
      }
  }
  // Wrong name or wrong arguments: null hands over to onUnknownRoute.
  return null;
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
