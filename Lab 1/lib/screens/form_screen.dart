import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/genre.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/dialogs.dart';

/// New and edit in one screen. Receives a Book? and returns a Book via pop.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // R33: one Form, one key, one validate() on Save.
  final _formKey = GlobalKey<FormState>();

  // R35: controllers and focus nodes are fields, created once, disposed.
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _copies;
  late final TextEditingController _notes;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _copiesFocus = FocusNode();
  final _notesFocus = FocusNode();

  Genre? _genre;
  DateTime? _date;
  TimeOfDay? _time;
  late bool _online;
  bool _saving = false;

  // R30: what the form opened with, to compare against.
  late final String _initialTitle;
  late final String _initialPlace;
  late final String _initialCopies;
  late final String _initialNotes;
  late final Genre? _initialGenre;
  late final DateTime? _initialDate;
  late final TimeOfDay? _initialTime;
  late final bool _initialOnline;

  Book? get _editing => widget.args.book;
  bool get _isEdit => _editing != null;

  @override
  void initState() {
    super.initState();
    final editing = _editing;
    // R3: defaults for a new book come from Book.empty().
    final base = editing ?? Book.empty();

    _title = TextEditingController(text: base.title);
    _place = TextEditingController(text: base.place);
    _copies = TextEditingController(text: base.copies.toString());
    _notes = TextEditingController(text: base.notes ?? '');
    _online = base.online;

    if (editing != null) {
      _genre = editing.genre;
      _date = DateTime(
        editing.meeting.year,
        editing.meeting.month,
        editing.meeting.day,
      );
      _time = TimeOfDay(
        hour: editing.meeting.hour,
        minute: editing.meeting.minute,
      );
    }
    final date = _date;
    final time = _time;
    _dateText = TextEditingController(
      text: date == null ? '' : formatDay(date),
    );
    _timeText = TextEditingController(
      text: time == null ? '' : formatClock(time.hour, time.minute),
    );

    _initialTitle = _title.text;
    _initialPlace = _place.text;
    _initialCopies = _copies.text;
    _initialNotes = _notes.text;
    _initialGenre = _genre;
    _initialDate = _date;
    _initialTime = _time;
    _initialOnline = _online;
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _copies.dispose();
    _notes.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _copiesFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  /// R30: current values against the ones the form opened with.
  bool get _dirty =>
      _title.text != _initialTitle ||
      _place.text != _initialPlace ||
      _copies.text != _initialCopies ||
      _notes.text != _initialNotes ||
      _genre != _initialGenre ||
      _date != _initialDate ||
      _time != _initialTime ||
      _online != _initialOnline;

  DateTime? get _combined {
    final date = _date;
    final time = _time;
    if (date == null || time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // ---- validators (R34) ----

  String? _validateTitle(String? value) {
    final length = (value ?? '').trim().length;
    if (length < 3 || length > 60) {
      return 'Title must be 3 to 60 characters';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _online ? 'Meeting link is required' : 'Place is required';
    }
    if (_online && !text.contains('://')) {
      return 'A link must contain ://';
    }
    return null;
  }

  String? _validateCopies(String? value) {
    final copies = int.tryParse((value ?? '').trim());
    if (copies == null || copies < 1 || copies > 500) {
      return 'Enter a whole number from 1 to 500';
    }
    final editing = _editing;
    if (editing != null && copies < editing.count) {
      return 'Not below the ${editing.count} readers already on the list';
    }
    return null;
  }

  String? _validateGenre(Genre? value) {
    return value == null ? 'Pick a category' : null;
  }

  String? _validateDate(String? value) {
    return _date == null ? 'Pick a date' : null;
  }

  String? _validateTime(String? value) {
    final combined = _combined;
    if (_time == null) {
      return 'Pick a time';
    }
    if (!_isEdit && combined != null && !combined.isAfter(DateTime.now())) {
      return 'A new meeting must be in the future';
    }
    return null;
  }

  // ---- pickers (R36) ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    // Cancel returns null: the old value stays.
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _date = picked;
      _dateText.text = formatDay(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _time = picked;
      _timeText.text = formatClock(picked.hour, picked.minute);
    });
  }

  // ---- save (R17) ----

  Future<void> _save() async {
    // A double tap while saving does nothing.
    if (_saving) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final meeting = _combined;
    final genre = _genre;
    if (meeting == null || genre == null) {
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }
    final base = _editing ?? Book.empty();
    final notes = _notes.text.trim();
    final book = base.copyWith(
      id: base.id.isEmpty
          ? 'b${DateTime.now().microsecondsSinceEpoch}'
          : base.id,
      title: _title.text.trim(),
      genre: genre,
      meeting: meeting,
      place: _place.text.trim(),
      copies: int.parse(_copies.text.trim()),
      online: _online,
      notes: notes,
      clearNotes: notes.isEmpty,
    );
    Navigator.of(context).pop(book);
  }

  Future<void> _confirmLeave() async {
    final discard = await confirmDialog(
      context,
      title: 'Discard changes?',
      message: 'Your changes to this book will be lost.',
      confirmLabel: 'Discard',
    );
    if (discard != true || !mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _dismissKeyboard(PointerDownEvent _) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // R30: a clean form pops freely; a dirty one asks. The AppBar arrow and
    // the Android back gesture both go through this PopScope.
    return PopScope<Book>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Edit book' : 'New book')),
        // R37: the whole form scrolls and Save is the last item in it.
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // Rebuild so canPop follows every edit.
          onChanged: () => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                maxLength: 60,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                validator: _validateTitle,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                onTapOutside: _dismissKeyboard,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Genre>(
                initialValue: _genre,
                validator: _validateGenre,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final genre in Genre.values)
                    DropdownMenuItem(
                      value: genre,
                      child: Row(
                        children: [
                          Icon(genre.icon),
                          const SizedBox(width: 12),
                          Text(genre.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _genre = value),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online meeting'),
                subtitle: const Text('The place becomes a link'),
                value: _online,
                onChanged: (value) => setState(() => _online = value),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _place,
                focusNode: _placeFocus,
                textInputAction: TextInputAction.next,
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validatePlace,
                onFieldSubmitted: (_) => _copiesFocus.requestFocus(),
                onTapOutside: _dismissKeyboard,
                decoration: InputDecoration(
                  labelText: _online ? 'Meeting link' : 'Place',
                  hintText: _online ? 'https://...' : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _copies,
                focusNode: _copiesFocus,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validator: _validateCopies,
                onFieldSubmitted: (_) => _pickDate(),
                onTapOutside: _dismissKeyboard,
                decoration: const InputDecoration(
                  labelText: 'Copies (limit)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateText,
                      readOnly: true,
                      validator: _validateDate,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.event),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeText,
                      readOnly: true,
                      validator: _validateTime,
                      onTap: _pickTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        suffixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                focusNode: _notesFocus,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onTapOutside: _dismissKeyboard,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
