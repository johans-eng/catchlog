import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../widgets/app_background.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Hive.box('entries').values.toList();

    final daily = <String, int>{};

    for (var e in items) {
      final t = DateTime.fromMillisecondsSinceEpoch(e['time']);
      final key = DateFormat('d MMM yyyy').format(t);
      daily[key] = (daily[key] ?? 0) + 1;
    }

    return AppBackground(
      showGlow: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenTitle(title: 'Calendar'),
              const SizedBox(height: 24),
              Expanded(
                child: daily.isEmpty
                    ? const Center(
                        child: Text(
                          'Nog geen entries',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      )
                    : ListView(
                        children: daily.entries.map((e) {
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                Text(
                                  '${e.value} dieven',
                                  style: const TextStyle(
                                    color: Color(0xFF0A84FF),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
