import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_branding.dart';
import '../services/entry_store.dart';
import '../utils/day_clock.dart';
import '../utils/entry_stats.dart';
import '../constants/outcomes.dart';
import '../widgets/app_background.dart';
import '../widgets/tab_safe_area.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = EntryStore.instance;

    Widget buildWith(List<Map<String, dynamic>> items) {
      return ListenableBuilder(
        listenable: DayClock.instance,
        builder: (context, _) => _buildStats(items),
      );
    }

    if (store.usesCloud) {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: store.watchEntries(),
        builder: (context, snapshot) =>
            buildWith(snapshot.data ?? []),
      );
    }

    return ValueListenableBuilder(
      valueListenable: store.localListenable,
      builder: (context, _, __) => buildWith(store.localEntries),
    );
  }

  Widget _buildStats(List<Map<String, dynamic>> items) {
        final outcomeCounts = _countOutcomes(items);
        final total = items.length;
        final dailyThieves = _dailyThieves(items, 7);
        final dailyAmounts = _dailyAmounts(items, 7);

        return AppScaffold(
          showGlow: false,
          body: TabSafeArea(
            child: items.isEmpty
                ? _emptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ScreenTitle(
                          title: 'Stats',
                          subtitle: "Overzicht van ${AppBranding.name}",
                        ),
                        const SizedBox(height: 28),
                        _sectionLabel('UITKOMSTEN'),
                        const SizedBox(height: 12),
                        ...Outcomes.all.map((outcome) {
                          final count = outcomeCounts[outcome] ?? 0;
                          final pct = total == 0 ? 0.0 : (count / total) * 100;
                          return _outcomeRow(outcome, count, pct);
                        }),
                        const SizedBox(height: 28),
                        _sectionLabel('DIEVEN PER DAG'),
                        const SizedBox(height: 12),
                        AppCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                          child: SizedBox(
                            height: 200,
                            child: _thievesChart(dailyThieves),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _sectionLabel('WAARDE PER DAG (€)'),
                        const SizedBox(height: 12),
                        AppCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                          child: SizedBox(
                            height: 200,
                            child: _amountsChart(dailyAmounts),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppCard(
                          margin: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _summaryItem('Totaal', '$total'),
                              _summaryItem(
                                'Vandaag',
                                '${countTodayEntries(items)}',
                              ),
                              _summaryItem(
                                'Waarde',
                                '€${totalValue(items)}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppCard(
                          margin: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _summaryItem(
                                'Vandaag €',
                                '€${todayValue(items)}',
                              ),
                              _summaryItem(
                                'Streak',
                                '${currentStreak(items)}d',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'Nog geen data.\nLog een dief op het home scherm.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 15,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF8E8E93),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _outcomeRow(String outcome, int count, double pct) {
    final color = Outcomes.colorFor(outcome);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      outcome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$count ${count == 1 ? 'keer' : 'keer'}',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 12,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _thievesChart(Map<DateTime, int> daily) {
    final entries = daily.entries.toList();
    final maxY = entries.map((e) => e.value).fold(1, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY.toDouble() + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) {
                  return const SizedBox.shrink();
                }
                final day = entries[i].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('E').format(day).substring(0, 2),
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 11,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(entries.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entries[i].value.toDouble(),
                color: const Color(0xFF0A84FF),
                width: 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _amountsChart(Map<DateTime, int> daily) {
    final entries = daily.entries.toList();
    if (entries.every((e) => e.value == 0)) {
      return const Center(
        child: Text(
          'Geen waarde geregistreerd',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            decoration: TextDecoration.none,
          ),
        ),
      );
    }

    final maxY = entries.map((e) => e.value).fold(1, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY.toDouble() + 2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) {
                  return const SizedBox.shrink();
                }
                final day = entries[i].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('d/M').format(day),
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 11,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              entries.length,
              (i) => FlSpot(i.toDouble(), entries[i].value.toDouble()),
            ),
            isCurved: true,
            color: const Color(0xFF30D158),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF30D158),
                strokeWidth: 2,
                strokeColor: const Color(0xFF1C1C1E),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF30D158).withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _countOutcomes(List<dynamic> items) {
    final counts = <String, int>{};
    for (final outcome in Outcomes.all) {
      counts[outcome] = 0;
    }
    for (final e in items) {
      final outcome = e['outcome'] as String?;
      if (outcome != null && counts.containsKey(outcome)) {
        counts[outcome] = counts[outcome]! + 1;
      }
    }
    return counts;
  }

  Map<DateTime, int> _dailyThieves(List<dynamic> items, int days) {
    return _dailyMap(items, days, (e) => 1);
  }

  Map<DateTime, int> _dailyAmounts(List<dynamic> items, int days) {
    return _dailyMap(items, days, entryValue);
  }

  Map<DateTime, int> _dailyMap(
    List<dynamic> items,
    int days,
    int Function(dynamic) valueFor,
  ) {
    final now = DateTime.now();
    final result = <DateTime, int>{};

    for (var i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      result[day] = 0;
    }

    for (final e in items) {
      final t = DateTime.fromMillisecondsSinceEpoch(e['time']);
      final day = DateTime(t.year, t.month, t.day);
      if (result.containsKey(day)) {
        result[day] = result[day]! + valueFor(e);
      }
    }

    return result;
  }
}
