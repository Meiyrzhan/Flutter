import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

enum _DetailAction { edit, delete }

/// Pushed from a card. It keeps its own copy of the item, applies changes to
/// it and reports them to the shell through the callbacks in [DetailArgs].
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late GameNight _night;
  late DateTime _now;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _night = widget.args.item;
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _you => widget.args.profileName.trim();

  bool get _joined => _you.isNotEmpty && _night.contains(_you);

  void _apply(GameNight updated) {
    setState(() => _night = updated);
    widget.args.onChanged(updated);
  }

  void _askForName() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Set your name in the profile first'),
        action: SnackBarAction(
          label: 'Profile',
          onPressed: () {
            // The snack bar can outlive this screen.
            if (mounted) {
              Navigator.of(context).pop();
            }
            widget.args.onOpenProfile();
          },
        ),
      ),
    );
  }

  Future<void> _join() async {
    if (_you.isEmpty) {
      _askForName();
      return;
    }
    final confirmed = await showConfirm(
      context,
      title: 'Join this night?',
      message: 'Add "$_you" to ${_night.title}?',
      confirmLabel: 'Join',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    _apply(_night.copyWith(players: [..._night.players, _you]));
  }

  void _leave() {
    _apply(
      _night.copyWith(
        players: _night.players.where((name) => name != _you).toList(),
      ),
    );
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).pushNamed<GameNight>(
      Routes.form,
      arguments: FormArgs(item: _night),
    );
    if (updated == null || !mounted) {
      return;
    }
    _apply(updated);
  }

  Future<void> _delete() async {
    final confirmed = await showConfirm(
      context,
      title: 'Delete this night?',
      message: '"${_night.title}" will be removed from the list.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !mounted) {
      return;
    }
    widget.args.onDelete(_night.id);
    Navigator.of(context).pop();
  }

  void _onMenu(_DetailAction action) {
    switch (action) {
      case _DetailAction.edit:
        _edit();
      case _DetailAction.delete:
        _delete();
    }
  }

  Widget _header(ThemeData theme) {
    final scheme = theme.colorScheme;
    final category = _night.category;
    final chipStyle = theme.textTheme.labelLarge?.copyWith(
      color: scheme.onSecondaryContainer,
    );
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/header.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                ColoredBox(color: category.colorOf(scheme)),
          ),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: category.colorOf(scheme),
              child: Icon(
                category.icon,
                size: 40,
                color: category.onColorOf(scheme),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Chip(
              label: Text(category.label, style: chipStyle),
              backgroundColor: scheme.secondaryContainer,
              side: BorderSide.none,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Chip(
              label: Text(
                describeCountdown(_night.countdownAt(_now)),
                style: chipStyle,
              ),
              backgroundColor: scheme.secondaryContainer,
              side: BorderSide.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton() {
    if (_joined) {
      return FilledButton.tonal(
        onPressed: _night.isPast ? null : _leave,
        child: const Text('Leave'),
      );
    }
    return FilledButton(
      onPressed: _night.isFull || _night.isPast ? null : _join,
      child: const Text('Join'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _night.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_DetailAction>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem<_DetailAction>(
                  value: _DetailAction.edit,
                  child: Text('Edit'),
                ),
                PopupMenuItem<_DetailAction>(
                  value: _DetailAction.delete,
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _header(theme),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Players (${_night.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(night: _night),
                  _PlayersTab(
                    night: _night,
                    you: _you,
                    onJoin: _night.isFull || _night.isPast || _joined
                        ? null
                        : _join,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: _actionButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.night});

  final GameNight night;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = night.places;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(
          icon: Icons.event,
          label: 'When',
          value: formatDate(night.startsAt),
        ),
        _InfoRow(
          icon: night.online ? Icons.link : Icons.place,
          label: night.online ? 'Link' : 'Venue',
          value: night.place,
        ),
        _InfoRow(
          icon: Icons.event_seat,
          label: 'Places',
          value: '$taken taken, $free free (of ${night.seats})',
        ),
        if (night.notes case final notes?)
          _InfoRow(icon: Icons.notes, label: 'Notes', value: notes),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.labelMedium),
                Text(value, style: text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  const _PlayersTab({
    required this.night,
    required this.you,
    required this.onJoin,
  });

  final GameNight night;
  final String you;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (night.players.isEmpty) {
      return EmptyState(
        icon: Icons.group_off,
        message: 'Nobody has joined yet',
        actionLabel: onJoin == null ? null : 'Be the first',
        onAction: onJoin,
      );
    }
    return ListView(
      children: [
        for (final name in night.players)
          ListTile(
            selected: you.isNotEmpty && name == you,
            selectedTileColor: theme.colorScheme.primaryContainer,
            title: Text(
              you.isNotEmpty && name == you ? 'You' : name,
              style: you.isNotEmpty && name == you
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.bodyLarge,
            ),
          ),
      ],
    );
  }
}
