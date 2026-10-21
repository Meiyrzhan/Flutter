import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/profile.dart';

/// Tab 3: the profile and the theme mode.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.books,
    required this.onProfileChanged,
    required this.themeMode,
    required this.onThemeMode,
  });

  final Profile profile;
  final List<Book> books;
  final ValueChanged<Profile> onProfileChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // R38: a group looks like IT-2301 (or is empty).
  static final _groupPattern = RegExp(r'^([A-Z]{2,5}-\d{3,4})?$');

  final _groupKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;
  final _groupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The shell can replace the profile (Reset data): follow it, but only
    // when the model changed, so unsaved typing survives other rebuilds.
    if (oldWidget.profile.name != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  void _saveName(String value) {
    widget.onProfileChanged(widget.profile.copyWith(name: value.trim()));
  }

  void _saveGroup(String value) {
    if (_groupKey.currentState?.validate() ?? false) {
      widget.onProfileChanged(widget.profile.copyWith(group: value.trim()));
    }
  }

  String? _validateGroup(String? value) {
    return _groupPattern.hasMatch((value ?? '').trim())
        ? null
        : 'Use a group like IT-2301';
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  void _dismiss(PointerDownEvent _) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // R38: computed from the list on every build, never stored.
    final lists = widget.books
        .where((book) => book.contains(widget.profile.name))
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('You are on $lists lists', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) {
            _saveName(value);
            _groupFocus.requestFocus();
          },
          onTapOutside: _dismiss,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Press Done to save',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Form(
          key: _groupKey,
          child: TextFormField(
            controller: _group,
            focusNode: _groupFocus,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validateGroup,
            onFieldSubmitted: _saveGroup,
            onTapOutside: _dismiss,
            decoration: const InputDecoration(
              labelText: 'Group',
              helperText: 'Press Done to save',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_modeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeMode(mode),
              ),
          ],
        ),
      ],
    );
  }
}
