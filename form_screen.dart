import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_category.dart';
import '../models/game_night.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

/// Everything the person can change, in one comparable value. PopScope
/// compares the current values with the ones the form opened with.
typedef _FormValues = ({
  String title,
  GameCategory? category,
  bool online,
  String place,
  String seats,
  DateTime? date,
  TimeOfDay? time,
  String notes,
});

/// New and edit in one screen. Receives an optional item and returns the
/// saved item through Navigator.pop.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _placeKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _timeKey =
      GlobalKey<FormFieldState<String>>();

  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _seats;
  late final TextEditingController _notes;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _placeFocus = FocusNode();
  final FocusNode _seatsFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  late final _FormValues _initial;

  GameCategory? _category;
  bool _online = false;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  bool _saved = false;

  bool get _isNew => widget.args.item == null;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.item;
    // New-item defaults come from the named constructor.
    final base = existing ?? GameNight.empty();

    _title = TextEditingController(text: base.title);
    _place = TextEditingController(text: base.place);
    _seats = TextEditingController(text: base.seats.toString());
    _notes = TextEditingController(text: base.notes ?? '');
    _online = base.online;

    DateTime? date;
    TimeOfDay? time;
    if (existing != null) {
      _category = existing.category;
      date = DateTime(
        existing.startsAt.year,
        existing.startsAt.month,
        existing.startsAt.day,
      );
      time = TimeOfDay(
        hour: existing.startsAt.hour,
        minute: existing.startsAt.minute,
      );
    }
    _date = date;
    _time = time;
    _dateText = TextEditingController(
      text: date == null ? '' : formatDayYear(date),
    );
    _timeText = TextEditingController(
      text: time == null ? '' : formatTime(time.hour, time.minute),
    );

    _initial = _current();
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _seats.dispose();
    _notes.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _seatsFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  _FormValues _current() {
    return (
      title: _title.text,
      category: _category,
      online: _online,
      place: _place.text,
      seats: _seats.text,
      date: _date,
      time: _time,
      notes: _notes.text,
    );
  }

  bool get _dirty => !_saved && _current() != _initial;

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _dismissKeyboard(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ---- validators -------------------------------------------------------

  String? _validateTitle(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 3) {
      return 'Title needs at least 3 characters';
    }
    if (text.length > 60) {
      return 'Title can have at most 60 characters';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _online ? 'A link is required' : 'A venue is required';
    }
    if (_online && !text.contains('://')) {
      return 'Enter a full link, for example https://meet.example.com/room';
    }
    return null;
  }

  String? _validateSeats(String? value) {
    final seats = int.tryParse((value ?? '').trim());
    if (seats == null) {
      return 'Enter a whole number';
    }
    if (seats < 1 || seats > 500) {
      return 'Between 1 and 500 players';
    }
    final existing = widget.args.item;
    if (existing != null && seats < existing.count) {
      return 'Already ${existing.count} players on the list';
    }
    return null;
  }

  String? _validateCategory(GameCategory? value) {
    return value == null ? 'Choose a category' : null;
  }

  String? _validateDate() {
    final date = _date;
    if (date == null) {
      return 'Pick a date';
    }
    final now = DateTime.now();
    if (_isNew && date.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'The date must be in the future';
    }
    return null;
  }

  String? _validateTime() {
    final date = _date;
    final time = _time;
    if (time == null) {
      return 'Pick a time';
    }
    if (_isNew &&
        date != null &&
        _combine(date, time).isBefore(DateTime.now())) {
      return 'The time must be in the future';
    }
    return null;
  }

  String? _validateNotes(String? value) {
    if ((value ?? '').length > 200) {
      return 'At most 200 characters';
    }
    return null;
  }

  // ---- pickers ----------------------------------------------------------

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _date;
    final firstDate =
        current != null && current.isBefore(today) ? current : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? today,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 5),
    );
    // Cancel keeps the old value.
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    _dateText.text = formatDayYear(picked);
    if (_time != null) {
      _timeKey.currentState?.validate();
    }
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _time = picked);
    _timeText.text = formatTime(picked.hour, picked.minute);
  }

  // ---- save and leave ---------------------------------------------------

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    final category = _category;
    final date = _date;
    final time = _time;
    if (category == null || date == null || time == null) {
      return;
    }

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    final existing = widget.args.item;
    final base = existing ?? GameNight.empty();
    final notes = _notes.text.trim();
    final result = base.copyWith(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      category: category,
      startsAt: _combine(date, time),
      seats: int.tryParse(_seats.text.trim()) ?? base.seats,
      online: _online,
      place: _place.text.trim(),
      notes: notes.isEmpty ? null : notes,
      clearNotes: notes.isEmpty,
    );

    setState(() => _saved = true);
    Navigator.of(context).pop(result);
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }
    final discard = await showConfirm(
      context,
      title: 'Discard changes?',
      message: 'Your edits will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      destructive: true,
    );
    if (discard != true || !mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  // ---- build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // The text controllers do not rebuild State, so PopScope listens to them.
    return ListenableBuilder(
      listenable: Listenable.merge([_title, _place, _seats, _notes]),
      builder: (context, _) => PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: _onPopInvoked,
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New game night' : 'Edit game night'),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                maxLength: 60,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                onTapOutside: _dismissKeyboard,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                validator: _validateTitle,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<GameCategory>(
                initialValue: _category,
                isExpanded: true,
                validator: _validateCategory,
                onChanged: (value) => setState(() => _category = value),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in GameCategory.values)
                    DropdownMenuItem<GameCategory>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon),
                          const SizedBox(width: 12),
                          Text(category.label),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online'),
                subtitle: Text(
                  _online
                      ? 'Players join through a link'
                      : 'Players meet at a venue',
                ),
                value: _online,
                onChanged: (value) {
                  setState(() => _online = value);
                  // The place field changes meaning: check it again.
                  if (_place.text.isNotEmpty) {
                    _placeKey.currentState?.validate();
                  }
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: _placeKey,
                controller: _place,
                focusNode: _placeFocus,
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                textInputAction: TextInputAction.next,
                onTapOutside: _dismissKeyboard,
                onFieldSubmitted: (_) => _seatsFocus.requestFocus(),
                validator: _validatePlace,
                decoration: InputDecoration(
                  labelText: _online ? 'Link' : 'Venue',
                  hintText: _online
                      ? 'https://meet.example.com/room'
                      : 'Where do you meet?',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seats,
                focusNode: _seatsFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                onTapOutside: _dismissKeyboard,
                onFieldSubmitted: (_) => _notesFocus.requestFocus(),
                validator: _validateSeats,
                decoration: const InputDecoration(
                  labelText: 'Seats (limit)',
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
                      onTap: _pickDate,
                      validator: (_) => _validateDate(),
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: _timeKey,
                      controller: _timeText,
                      readOnly: true,
                      onTap: _pickTime,
                      validator: (_) => _validateTime(),
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
                maxLength: 200,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                onTapOutside: _dismissKeyboard,
                validator: _validateNotes,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
