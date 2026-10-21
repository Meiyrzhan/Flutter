import '../models/game_night.dart';

/// Upcoming first (soonest first), past items last. Sorts a copy, never the
/// list that lives in the shell's State.
List<GameNight> sortedByDate(Iterable<GameNight> nights) {
  final copy = [...nights];
  copy.sort((a, b) {
    if (a.isPast != b.isPast) {
      return a.isPast ? 1 : -1;
    }
    return a.startsAt.compareTo(b.startsAt);
  });
  return copy;
}
