/// Where a game night is relative to "now". Rendered by an exhaustive switch
/// in utils/format.dart.
sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}
