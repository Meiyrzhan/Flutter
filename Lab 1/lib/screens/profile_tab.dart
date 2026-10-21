import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../models/profile.dart';

/// Tab 3: name, group and the theme mode.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.nights,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<GameNight> nights;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Two to four capital letters, a dash, three or four digits: CS-2301.
  static final RegExp _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{3,4}$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _groupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // "Reset data" in the drawer clears the profile from outside.
    if (oldWidget.profile.name != widget.profile.name &&
        _name.text != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group &&
        _group.text != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    if (text.length < 2) {
      return 'Use at least 2 characters';
    }
    return null;
  }

  String? _validateGroup(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty || _groupPattern.hasMatch(text)) {
      return null;
    }
    return 'Use a format like CS-2301';
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    widget.onProfileChanged(
      widget.profile.copyWith(
        name: _name.text.trim(),
        group: _group.text.trim(),
      ),
    );
  }

  String _modeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    // Computed from the list on every build, never stored.
    final listCount =
        widget.nights.where((night) => night.contains(name)).length;
    final noun = listCount == 1 ? 'list' : 'lists';
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(initial, style: theme.textTheme.headlineMedium),
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  focusNode: _nameFocus,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onFieldSubmitted: (_) {
                    _save();
                    _groupFocus.requestFocus();
                  },
                  validator: _validateName,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _group,
                  focusNode: _groupFocus,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.characters,
                  onTapOutside: (event) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onFieldSubmitted: (_) => _save(),
                  validator: _validateGroup,
                  decoration: const InputDecoration(
                    labelText: 'Group',
                    hintText: 'CS-2301',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      _save();
                      FocusScope.of(context).unfocus();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You are on $listCount $noun',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Theme', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final mode in ThemeMode.values)
                ChoiceChip(
                  label: Text(_modeLabel(mode)),
                  selected: widget.themeMode == mode,
                  onSelected: (_) => widget.onThemeModeChanged(mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
