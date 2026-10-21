import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/game_night.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/confirm_dialog.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

/// The shell owns the item list and the profile. Tabs get them as
/// constructor parameters and send changes up through callbacks.
class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const List<String> _titles = ['Game nights', 'Favourites', 'Profile'];

  List<GameNight> _nights = buildSeed();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _goTo(int index) {
    setState(() => _tab = index);
  }

  void _add(GameNight night) {
    setState(() => _nights = [night, ..._nights]);
  }

  void _replace(GameNight updated) {
    setState(() {
      _nights = [
        for (final night in _nights)
          if (night.id == updated.id) updated else night,
      ];
    });
  }

  void _remove(String id) {
    setState(() => _nights = _nights.where((night) => night.id != id).toList());
  }

  void _toggleFavourite(String id) {
    setState(() {
      _nights = [
        for (final night in _nights)
          if (night.id == id)
            night.copyWith(favourite: !night.favourite)
          else
            night,
      ];
    });
  }

  void _changeProfile(Profile profile) {
    setState(() => _profile = profile);
  }

  Future<void> _createNight() async {
    final created = await Navigator.of(context).pushNamed<GameNight>(
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) {
      return;
    }
    _add(created);
  }

  void _openDetail(GameNight night) {
    Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailArgs(
        item: night,
        profileName: _profile.name,
        onChanged: _replace,
        onDelete: _remove,
        onOpenProfile: () => _goTo(2),
      ),
    );
  }

  void _showAbout() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Game Nights - find a board game night, see who is coming and '
          'join it. Mobile Development, Lab 1. All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.of(context).pop();
    final confirmed = await showConfirm(
      context,
      title: 'Reset data?',
      message: 'This restores the seed nights and clears your profile.',
      confirmLabel: 'Reset',
      destructive: true,
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() {
      _nights = buildSeed();
      _profile = const Profile.empty();
    });
  }

  Widget _buildDrawer() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primaryContainer),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Game Nights',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 16),
                Text('About'),
              ],
            ),
            onTap: _showAbout,
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.restart_alt),
                SizedBox(width: 16),
                Text('Reset data'),
              ],
            ),
            onTap: _resetData,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFavourites = _nights.any((night) => night.favourite);

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _tab,
        children: [
          ListTab(
            nights: _nights,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
            onCreate: _createNight,
          ),
          FavouritesTab(
            nights: _nights,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
            onBrowse: () => _goTo(0),
          ),
          ProfileTab(
            profile: _profile,
            nights: _nights,
            themeMode: widget.themeMode,
            onProfileChanged: _changeProfile,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goTo,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Nights',
          ),
          NavigationDestination(
            icon: Icon(hasFavourites ? Icons.favorite : Icons.favorite_border),
            label: 'Favourites',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
