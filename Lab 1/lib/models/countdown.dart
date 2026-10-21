/// R9: what the clock says about a meeting.
sealed class Countdown {
  const Countdown();

  /// A meeting counts as "started" for two hours, then it has ended.
  factory Countdown.until(DateTime when) {
    final now = DateTime.now();
    if (now.isBefore(when)) {
      return Upcoming(when.difference(now));
    }
    final since = now.difference(when);
    return since < _liveWindow ? Started(since) : const Ended();
  }
}

const _liveWindow = Duration(hours: 2);

final class Upcoming extends Countdown {
  const Upcoming(this.left);

  final Duration left;
}

final class Started extends Countdown {
  const Started(this.since);

  final Duration since;
}

final class Ended extends Countdown {
  const Ended();
}
