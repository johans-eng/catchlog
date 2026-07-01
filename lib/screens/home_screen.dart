import 'package:flutter/material.dart';

import '../constants/app_branding.dart';
import '../constants/outcomes.dart';
import '../services/app_config.dart';
import '../services/entry_store.dart';
import '../services/firebase_service.dart';
import '../utils/day_clock.dart';
import '../utils/entry_stats.dart';
import '../widgets/jopies_logo.dart';
import '../widgets/app_button.dart';
import '../widgets/tab_safe_area.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/app_background.dart';
import 'glow_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final store = EntryStore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DayClock.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    DayClock.instance.removeListener(_refresh);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isViewer = AppConfig.isViewer;

    if (store.usesCloud) {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: store.watchEntries(),
        builder: (context, snapshot) =>
            _buildBody(isViewer, snapshot.data ?? []),
      );
    }

    return ValueListenableBuilder(
      valueListenable: store.localListenable,
      builder: (context, _, __) => _buildBody(isViewer, store.localEntries),
    );
  }

  Widget _buildBody(bool isViewer, List<Map<String, dynamic>> entries) {
    final todayCount = store.todayCountFrom(entries);
    final totalCount = store.totalCountFrom(entries);
    final todayEuro = todayValue(entries);
    final totalEuro = totalValue(entries);
    final streak = currentStreak(entries);
    final latest = lastEntry(entries);
    final isActive = todayCount > 0;

    return AppScaffold(
      body: TabSafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    JopiesLogo(size: 56),
                    const SizedBox(height: 12),
                    Text(
                      isViewer ? 'Live feed' : AppBranding.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isViewer
                          ? 'Updates automatisch wanneer er een dief is gelogd'
                          : AppBranding.tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (store.usesCloud) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF30D158),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Live sync',
                            style: TextStyle(
                              color: Color(0xFF30D158),
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ] else if (!isViewer &&
                        FirebaseService.isReady &&
                        AppConfig.roomCode.isEmpty) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Geen deelcode ingesteld — ga naar Settings om live sync te activeren.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.orange.withValues(alpha: 0.9),
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 36),
                    Center(child: GlowRing(value: todayCount)),
                    const SizedBox(height: 28),
                    _infoCard('TOTAAL GEVANGEN', '$totalCount'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard('WAARDE VANDAAG', '€$todayEuro'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard('WAARDE TOTAAL', '€$totalEuro'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _streakCard(streak),
                    if (latest != null) ...[
                      const SizedBox(height: 12),
                      _lastCatchCard(latest),
                    ],
                    const SizedBox(height: 12),
                    _statusCard(isActive),
                  ],
                ),
              ),
            ),
            if (!isViewer) _logButton(context),
            if (!isViewer) const SizedBox(height: 20),
            if (isViewer) const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _streakCard(int streak) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Color(0xFFFF9F0A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STREAK',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  streak == 0
                      ? 'Nog geen streak'
                      : '$streak ${streak == 1 ? 'dag' : 'dagen'} op rij',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastCatchCard(Map<String, dynamic> entry) {
    final outcome = entry['outcome'] as String? ?? 'Onbekend';
    final value = entryValue(entry);
    final time = entry['time'] as int? ?? 0;
    final color = Outcomes.colorFor(outcome);

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAATSTE VANGST',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${Outcomes.emojiFor(outcome)} $outcome',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Text(
                '€$value',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            timeAgo(time),
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logButton(BuildContext context) {
    return AppPrimaryButton(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      gradient: const LinearGradient(
        colors: [Color(0xFF0A84FF), Color(0xFF0066CC)],
      ),
      onPressed: () => showAddEntrySheet(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _infoCard(String title, String value) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(bool isActive) {
    final statusColor =
        isActive ? const Color(0xFF30D158) : const Color(0xFFFF9F0A);

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
