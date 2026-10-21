import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/book.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/dialogs.dart';
import 'favourites_tab.dart';
import 'library_tab.dart';
import 'profile_tab.dart';

/// The shell: NavigationBar with three tabs and a drawer.
///
/// R10: the book list and the profile live in this State. Tabs receive them
/// as constructor parameters and send changes up through callbacks.
class Shell extends StatefulWidget {
  const Shell({super.key, required this.themeMode, required this.onThemeMode});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _titles = ['Books', 'Favourites', 'Profile'];

  int _tab = 0;
  List<Book> _books = seedBooks();
  Profile _profile = const Profile.empty();

  // R28: one Navigator. Tabs and pushed screens switch tabs only via this.
  void _goToTab(int index) {
    setState(() => _tab = index);
  }

  void _toggleFavourite(Book book) {
    _replace(book.copyWith(favourite: !book.favourite));
  }

  /// A new list every time: the old one is never mutated.
  void _replace(Book updated) {
    setState(() {
      _books = [
        for (final book in _books)
          if (book.id == updated.id) updated else book,
      ];
    });
  }

  void _delete(String id) {
    setState(() {
      _books = _books.where((book) => book.id != id).toList();
    });
  }

  void _setProfile(Profile profile) {
    setState(() => _profile = profile);
  }

  void _open(Book book) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArgs(
        book: book,
        profileName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        onGoToProfile: () => _goToTab(2),
      ),
    );
  }

  /// R27: await, check null and mounted, then setState. Backing out of the
  /// form returns null and changes nothing.
  Future<void> _add() async {
    final created = await Navigator.of(
      context,
    ).pushNamed<Book>(Routes.form, arguments: const FormArgs());
    if (created == null || !mounted) {
      return;
    }
    setState(() => _books = [..._books, created]);
  }

  // R32: the tile closes the drawer first, then opens the dialog.
  void _about() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Book Club - a reading club app. Borrow a copy, meet the readers '
          'and see who else is coming. All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    Navigator.of(context).pop();
    final confirmed = await confirmDialog(
      context,
      title: 'Reset data?',
      message: 'This restores the seed books and clears your profile.',
      confirmLabel: 'Reset',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() {
      _books = seedBooks();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Book Club',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 16),
                    Text('About'),
                  ],
                ),
                onTap: _about,
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.restart_alt),
                    SizedBox(width: 16),
                    Text('Reset data'),
                  ],
                ),
                onTap: _reset,
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          LibraryTab(
            books: _books,
            onOpen: _open,
            onToggleFavourite: _toggleFavourite,
            onAdd: _add,
          ),
          FavouritesTab(
            books: _books,
            onOpen: _open,
            onToggleFavourite: _toggleFavourite,
            onBrowse: () => _goToTab(0),
          ),
          ProfileTab(
            profile: _profile,
            books: _books,
            onProfileChanged: _setProfile,
            themeMode: widget.themeMode,
            onThemeMode: widget.onThemeMode,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('New book'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
