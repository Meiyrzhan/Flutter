import '../models/countdown.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// 10:05 - minutes are padded with padLeft.
String formatTime(int hour, int minute) {
  return '$hour:${minute.toString().padLeft(2, '0')}';
}

/// 18 Oct
String formatDay(DateTime date) => '${date.day} ${_months[date.month - 1]}';

/// 18 Oct 2026
String formatDayYear(DateTime date) => '${formatDay(date)} ${date.year}';

/// 18 Oct, 10:00
String formatDate(DateTime date) {
  return '${formatDay(date)}, ${formatTime(date.hour, date.minute)}';
}

String formatDuration(Duration duration) {
  if (duration.inDays >= 1) {
    final hours = duration.inHours % 24;
    return hours == 0
        ? '${duration.inDays} d'
        : '${duration.inDays} d $hours h';
  }
  if (duration.inHours >= 1) {
    return '${duration.inHours} h ${duration.inMinutes % 60} min';
  }
  if (duration.inMinutes < 1) {
    return 'under a minute';
  }
  return '${duration.inMinutes} min';
}

/// Exhaustive switch over the sealed [Countdown].
String describeCountdown(Countdown countdown) {
  return switch (countdown) {
    Upcoming(:final remaining) => 'Starts in ${formatDuration(remaining)}',
    Started(:final elapsed) => 'Started ${formatDuration(elapsed)} ago',
    Ended() => 'Ended',
  };
}
