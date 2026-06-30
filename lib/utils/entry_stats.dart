bool isLocalToday(int millisecondsSinceEpoch) {
  final entry =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch).toLocal();
  final now = DateTime.now();
  return entry.year == now.year &&
      entry.month == now.month &&
      entry.day == now.day;
}

int countTodayEntries(Iterable<dynamic> entries) {
  return entries.where((e) {
    final time = e['time'];
    if (time is! int) return false;
    return isLocalToday(time);
  }).length;
}
