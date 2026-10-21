/// R8: our own formatting, no packages.
const _months = [
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

String _two(int value) => value.toString().padLeft(2, '0');

/// 18 Oct, 10:00
String formatDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]}, '
      '${formatClock(date.hour, date.minute)}';
}

/// 18 Oct 2026
String formatDay(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// 09:05
String formatClock(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

/// 2 d 3 h, 5 h 10 min, 42 min
String formatDuration(Duration duration) {
  if (duration.inDays > 0) {
    return '${duration.inDays} d ${duration.inHours % 24} h';
  }
  if (duration.inHours > 0) {
    return '${duration.inHours} h ${duration.inMinutes % 60} min';
  }
  return '${duration.inMinutes} min';
}
