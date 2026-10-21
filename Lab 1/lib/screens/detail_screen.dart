import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/countdown.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';
import '../widgets/icon_line.dart';

enum _MenuAction { edit, delete }

/// Pushed from a card. Gets the book and callbacks through [DetailArgs].
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Book _book;
  late Countdown _countdown;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _book = widget.args.book;
    _countdown = Countdown.until(_book.meeting);
    // R13: one-minute tick, created here, cancelled in dispose.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _countdown = Countdown.until(_book.meeting));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _name => widget.args.profileName.trim();

  void _apply(Book updated) {
    setState(() {
      _book = updated;
      _countdown = Countdown.until(updated.meeting);
    });
    widget.args.onChanged(updated);
  }

  /// R15: ask, then act on true. An empty profile name shows a SnackBar
  /// whose action switches to the profile tab.
  Future<void> _borrow() async {
    if (_name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              widget.args.onGoToProfile();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      );
      return;
    }
    final confirmed = await confirmDialog(
      context,
      title: 'Borrow this book?',
      message: 'Your name will be added to "${_book.title}".',
      confirmLabel: 'Borrow',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    _apply(_book.copyWith(readers: [..._book.readers, _name]));
  }

  void _giveBack() {
    final name = _name.toLowerCase();
    _apply(
      _book.copyWith(
        readers: _book.readers
            .where((reader) => reader.toLowerCase() != name)
            .toList(),
      ),
    );
  }

  Future<void> _edit() async {
    final edited = await Navigator.of(
      context,
    ).pushNamed<Book>(Routes.form, arguments: FormArgs(book: _book));
    if (edited == null || !mounted) {
      return;
    }
    _apply(edited);
  }

  Future<void> _delete() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete this book?',
      message: '"${_book.title}" will be removed from the list.',
      confirmLabel: 'Delete',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    widget.args.onDelete(_book.id);
    Navigator.of(context).pop();
  }

  String _countdownText(Countdown countdown) => switch (countdown) {
    Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
    Started(:final since) => 'Started ${since.inMinutes} min ago',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onList = _book.contains(_name);

    // R16: onPressed null when the action cannot happen. When your name is
    // on the list the primary action becomes its opposite.
    final VoidCallback? onPressed = onList
        ? _giveBack
        : (_book.isFull ? null : _borrow);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book'),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) => switch (action) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // R24: image from assets/, icon, category and countdown.
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/cover.png', fit: BoxFit.cover),
                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: scheme.surface,
                      child: Icon(
                        _book.genre.icon,
                        size: 36,
                        color: _book.genre.color(scheme),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Chip(
                      backgroundColor: scheme.surface,
                      label: Text(_book.genre.label),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Chip(
                      backgroundColor: scheme.surface,
                      label: Text(_countdownText(_countdown)),
                    ),
                  ),
                ],
              ),
            ),
            // R29: the count in the tab label is live.
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Readers (${_book.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(children: [_about(context), _readers(context)]),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: onPressed,
              child: Text(
                onList
                    ? 'Return'
                    : (_book.isFull ? 'No copies left' : 'Borrow'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _about(BuildContext context) {
    final theme = Theme.of(context);
    // R5: destructure the record where it is shown.
    final (:taken, :free) = _book.places;
    final notes = _book.notes;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_book.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        IconLine(
          icon: Icons.event,
          title: formatDate(_book.meeting),
          subtitle: 'Meeting',
        ),
        IconLine(
          icon: _book.online ? Icons.link : Icons.place,
          title: _book.place,
          subtitle: _book.online ? 'Online meeting link' : 'Place',
        ),
        IconLine(
          icon: Icons.library_books,
          title: '$taken of ${_book.copies} copies borrowed',
          subtitle: '$free left',
        ),
        if (notes != null)
          IconLine(icon: Icons.notes, title: notes, subtitle: 'Notes'),
      ],
    );
  }

  Widget _readers(BuildContext context) {
    final readers = _book.readers;
    if (readers.isEmpty) {
      return const EmptyState(
        icon: Icons.groups_outlined,
        message: 'Nobody has borrowed this book yet',
      );
    }
    final name = _name.toLowerCase();
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final reader in readers)
          if (reader.toLowerCase() == name)
            const IconLine(icon: Icons.person, title: 'You', highlighted: true)
          else
            IconLine(icon: Icons.person_outline, title: reader),
      ],
    );
  }
}
