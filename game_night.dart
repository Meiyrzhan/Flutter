import 'dart:collection';
import 'dart:math' as math;

import 'countdown.dart';
import 'game_category.dart';

/// One board game night. Immutable: every change goes through [copyWith].
class GameNight {
  const GameNight({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.seats,
    required List<String> players,
    required this.online,
    required this.place,
    this.notes,
    this.favourite = false,
  }) : _players = players;

  /// Defaults for a brand new night (used by the form).
  GameNight.empty()
      : id = '',
        title = '',
        category = GameCategory.strategy,
        startsAt = DateTime.now().add(const Duration(days: 1)),
        seats = 6,
        _players = const [],
        online = false,
        place = '',
        notes = null,
        favourite = false;

  /// How long a night lasts after it starts, before it counts as ended.
  static const Duration sessionLength = Duration(hours: 3);

  final String id;
  final String title;
  final GameCategory category;
  final DateTime startsAt;

  /// The limit the list of players counts against.
  final int seats;
  final List<String> _players;

  /// The mode: online means [place] is a link instead of a venue.
  final bool online;
  final String place;

  /// Optional text, shown only when present.
  final String? notes;
  final bool favourite;

  /// Read-only view: nobody outside can mutate the names.
  List<String> get players => UnmodifiableListView(_players);

  int get count => _players.length;
  int get freeSeats => math.max(0, seats - count);
  bool get isFull => count >= seats;
  bool get isPast => startsAt.isBefore(DateTime.now());

  bool contains(String name) => _players.contains(name);

  ({int taken, int free}) get places => (taken: count, free: freeSeats);

  Countdown countdownAt(DateTime now) {
    if (now.isBefore(startsAt)) {
      return Upcoming(startsAt.difference(now));
    }
    final elapsed = now.difference(startsAt);
    return elapsed < sessionLength ? Started(elapsed) : const Ended();
  }

  GameNight copyWith({
    String? id,
    String? title,
    GameCategory? category,
    DateTime? startsAt,
    int? seats,
    List<String>? players,
    bool? online,
    String? place,
    String? notes,
    bool clearNotes = false,
    bool? favourite,
  }) {
    return GameNight(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startsAt: startsAt ?? this.startsAt,
      seats: seats ?? this.seats,
      players: List.unmodifiable(players ?? _players),
      online: online ?? this.online,
      place: place ?? this.place,
      notes: clearNotes ? null : (notes ?? this.notes),
      favourite: favourite ?? this.favourite,
    );
  }
}
