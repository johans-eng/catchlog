import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../widgets/add_entry_sheet.dart';
import '../widgets/app_background.dart';
import 'glow_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box('entries');

  int get todayCount {
    final now = DateTime.now();

    return box.values.where((e) {
      final t = DateTime.fromMillisecondsSinceEpoch(e['time']);
      return t.day == now.day &&
          t.month == now.month &&
          t.year == now.year;
    }).length;
  }

  int get totalCount => box.length;

  bool get isActive => todayCount > 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, _, __) {
        return AppScaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'CatchLog',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Stay focused. Stay aware.',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: GlowRing(value: todayCount),
                ),
                const SizedBox(height: 35),
                _infoCard('TOTAL CAUGHT', '$totalCount'),
                const SizedBox(height: 15),
                _statusCard(),
                const Spacer(),
                _logButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _logButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF0A84FF), Color(0xFF0066CC)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A84FF).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => showAddEntrySheet(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Log dief',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    final statusColor =
        isActive ? const Color(0xFF30D158) : const Color(0xFFFF9F0A);

    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'STATUS',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              decoration: TextDecoration.none,
            ),
          ),
          Row(
            children: [
              Text(
                isActive ? 'ACTIVE' : 'IDLE',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.7),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
