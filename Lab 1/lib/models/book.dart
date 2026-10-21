import 'genre.dart';

/// One meeting of the reading club (the "Item" of the lab).
///
/// Immutable (R1): final fields, const constructor, [copyWith]. The readers
/// list is private and only exposed as an unmodifiable view.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.genre,
    required this.meeting,
    required this.place,
    required this.copies,
    required List<String> readers,
    required this.online,
    this.notes,
    this.favourite = false,
  }) : _readers = readers;

  /// R3: defaults for a new book come from a named constructor.
  Book.empty()
    : this(
        id: '',
        title: '',
        genre: Genre.fantasy,
        meeting: DateTime.now(),
        place: '',
        copies: 10,
        readers: const [],
        online: false,
      );

  final String id;
  final String title;
  final Genre genre;
  final DateTime meeting;

  /// A meeting place, or a link when [online] is true.
  final String place;

  /// The limit: how many copies exist.
  final int copies;
  final bool online;

  /// Optional text, shown only when present.
  final String? notes;
  final bool favourite;

  final List<String> _readers;

  List<String> get readers => List.unmodifiable(_readers);

  // R4: derived values are getters, never fields.
  int get count => _readers.length;
  int get free => copies - count < 0 ? 0 : copies - count;
  bool get isFull => count >= copies;
  bool get isPast => meeting.isBefore(DateTime.now());

  bool contains(String name) {
    final wanted = name.trim().toLowerCase();
    return wanted.isNotEmpty &&
        _readers.any((reader) => reader.toLowerCase() == wanted);
  }

  /// R5: the count against the limit as a record.
  ({int taken, int free}) get places => (taken: count, free: free);

  Book copyWith({
    String? title,
    Genre? genre,
    DateTime? meeting,
    String? place,
    int? copies,
    List<String>? readers,
    bool? online,
    String? notes,
    bool clearNotes = false,
    bool? favourite,
    String? id,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      meeting: meeting ?? this.meeting,
      place: place ?? this.place,
      copies: copies ?? this.copies,
      readers: List.unmodifiable(readers ?? _readers),
      online: online ?? this.online,
      notes: clearNotes ? null : (notes ?? this.notes),
      favourite: favourite ?? this.favourite,
    );
  }
}
