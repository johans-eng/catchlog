import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/entry_store.dart';
import '../utils/day_clock.dart';
import '../utils/entry_stats.dart';
import '../widgets/app_background.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  static const _weeks = 12;
  static const _accent = Color(0xFF0A84FF);

  @override
  Widget build(BuildContext context) {
    final store = EntryStore.instance;

    Widget buildWith(List<Map<String, dynamic>> items) {
      return ListenableBuilder(
        listenable: DayClock.instance,
        builder: (context, _) => _buildCalendar(items),
      );
    }

    if (store.usesCloud) {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: store.watchEntries(),
        builder: (context, snapshot) => buildWith(snapshot.data ?? []),
      );
    }

    return ValueListenableBuilder(
      valueListenable: store.localListenable,
      builder: (context, _, __) => buildWith(store.localEntries),
    );
  }

  Widget _buildCalendar(List<Map<String, dynamic>> items) {
    final counts = dailyCatchCounts(items);
    final today = DateTime.now();
    final startMonday = _mondayOf(
      DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: (_weeks * 7) - 1)),
    );
    final days = List.generate(_weeks * 7, (i) {
      return startMonday.add(Duration(days: i));
    });
    final maxCount = counts.values.fold(1, (a, b) => a > b ? a : b);

    return AppScaffold(
      showGlow: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenTitle(
                title: 'Calendar',
                subtitle: 'Heatmap van vangsten per dag',
              ),
              const SizedBox(height: 20),
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Laatste $_weeks weken',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          'Streak: ${currentStreak(items)} dagen',
                          style: const TextStyle(
                            color: Color(0xFFFF9F0A),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: ['M', 'D', 'W', 'D', 'V', 'Z', 'Z']
                          .map(
                            (d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    color: Color(0xFF8E8E93),
                                    fontSize: 11,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final key = DateTime(day.year, day.month, day.day);
                        final count = counts[key] ?? 0;
                        final intensity = count / maxCount;
                        final isToday = _isSameDay(key, today);

                        return Tooltip(
                          message: count == 0
                              ? DateFormat('d MMM').format(day)
                              : '${DateFormat('d MMM').format(day)}: $count vangst${count == 1 ? '' : 'en'}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: isToday
                                  ? Border.all(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      width: 1.5,
                                    )
                                  : null,
                              color: count == 0
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : _accent.withValues(
                                      alpha: 0.25 + (intensity * 0.75),
                                    ),
                            ),
                            alignment: Alignment.center,
                            child: count > 0
                                ? Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.none,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _legendBox(0),
                        const SizedBox(width: 6),
                        const Text(
                          'Geen',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const Spacer(),
                        _legendBox(0.35),
                        const SizedBox(width: 4),
                        _legendBox(0.7),
                        const SizedBox(width: 4),
                        _legendBox(1),
                        const SizedBox(width: 6),
                        const Text(
                          'Meer',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (items.isEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Nog geen vangsten om te tonen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendBox(double intensity) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: intensity == 0
            ? Colors.white.withValues(alpha: 0.06)
            : _accent.withValues(alpha: 0.25 + (intensity * 0.75)),
      ),
    );
  }

  DateTime _mondayOf(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
