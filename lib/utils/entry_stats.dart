bool isLocalToday(int millisecondsSinceEpoch) {
  final entry =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch).toLocal();
  final now = DateTime.now();
  return entry.year == now.year &&
      entry.month == now.month &&
      entry.day == now.day;
}

DateTime _dayKey(int millisecondsSinceEpoch) {
  final t = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch).toLocal();
  return DateTime(t.year, t.month, t.day);
}

int countTodayEntries(Iterable<dynamic> entries) {
  return entries.where((e) {
    final time = e['time'];
    if (time is! int) return false;
    return isLocalToday(time);
  }).length;
}

int entryValue(dynamic entry) => (entry['amount'] as int?) ?? 0;

int totalValue(Iterable<dynamic> entries) {
  return entries.fold<int>(0, (sum, e) => sum + entryValue(e));
}

int todayValue(Iterable<dynamic> entries) {
  return entries.where((e) {
    final time = e['time'];
    return time is int && isLocalToday(time);
  }).fold<int>(0, (sum, e) => sum + entryValue(e));
}

Map<DateTime, int> dailyCatchCounts(Iterable<dynamic> entries) {
  final counts = <DateTime, int>{};
  for (final e in entries) {
    final time = e['time'];
    if (time is! int) continue;
    final day = _dayKey(time);
    counts[day] = (counts[day] ?? 0) + 1;
  }
  return counts;
}

Map<DateTime, int> dailyValueTotals(Iterable<dynamic> entries) {
  final totals = <DateTime, int>{};
  for (final e in entries) {
    final time = e['time'];
    if (time is! int) continue;
    final day = _dayKey(time);
    totals[day] = (totals[day] ?? 0) + entryValue(e);
  }
  return totals;
}

int currentStreak(Iterable<dynamic> entries) {
  final days = dailyCatchCounts(entries).keys.toSet();
  if (days.isEmpty) return 0;

  final today = DateTime.now();
  var cursor = DateTime(today.year, today.month, today.day);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

Map<String, dynamic>? lastEntry(Iterable<dynamic> entries) {
  Map<String, dynamic>? latest;
  var latestTime = -1;

  for (final raw in entries) {
    if (raw is! Map) continue;
    final entry = Map<String, dynamic>.from(raw);
    final time = entry['time'];
    if (time is! int || time <= latestTime) continue;
    latestTime = time;
    latest = entry;
  }
  return latest;
}

String timeAgo(int millisecondsSinceEpoch) {
  final then =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch).toLocal();
  final diff = DateTime.now().difference(then);

  if (diff.inMinutes < 1) return 'zojuist';
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min geleden';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} uur geleden';
  }
  if (diff.inDays == 1) return 'gisteren';
  if (diff.inDays < 7) return '${diff.inDays} dagen geleden';
  return '${then.day}/${then.month}/${then.year}';
}
