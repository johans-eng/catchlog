import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/lock_screen.dart';
import 'services/app_config.dart';
import 'services/firebase_service.dart';
import 'utils/day_clock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
    _applyWebLaunchParams();
  }
  DayClock.instance;
  await Hive.initFlutter();
  await Hive.openBox('entries');
  await Hive.openBox('settings');
  await FirebaseService.init();

  runApp(const JopiesCatchesApp());
}

void _applyWebLaunchParams() {
  final room = Uri.base.queryParameters['room'];
  final viewer = Uri.base.queryParameters['viewer'];

  if (room != null && room.isNotEmpty) {
    AppConfig.roomCode = room;
  }
  if (viewer == '1') {
    AppConfig.isViewer = true;
  }
  final ntfy = Uri.base.queryParameters['ntfy'];
  if (ntfy != null && ntfy.isNotEmpty) {
    AppConfig.ntfyTopic = ntfy;
  }
}

class JopiesCatchesApp extends StatelessWidget {
  const JopiesCatchesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const noUnderline = TextDecoration.none;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050508),
        fontFamily: 'Roboto',
        textTheme: Typography.material2021().white.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
              decoration: noUnderline,
            ),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Color(0xFF0A84FF),
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              decoration: noUnderline,
              color: Colors.white,
            ),
          ),
        ),
      ),
      home: LockScreen(child: const RootPage()),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isViewer = AppConfig.isViewer;

    final items = isViewer
        ? const [
            (icon: CupertinoIcons.home, label: 'Live'),
            (icon: CupertinoIcons.chart_bar, label: 'Stats'),
            (icon: CupertinoIcons.calendar, label: 'Calendar'),
            (icon: CupertinoIcons.bell, label: 'Meldingen'),
          ]
        : const [
            (icon: CupertinoIcons.home, label: 'Home'),
            (icon: CupertinoIcons.chart_bar, label: 'Stats'),
            (icon: CupertinoIcons.calendar, label: 'Calendar'),
            (icon: CupertinoIcons.settings, label: 'Settings'),
          ];

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Color(0xFF0A84FF),
        backgroundColor: Color(0xFF1C1C1E),
        items: [
          for (final item in items)
            BottomNavigationBarItem(icon: Icon(item.icon), label: item.label),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const HomeScreen();
          case 1:
            return const StatsScreen();
          case 2:
            return const CalendarScreen();
          case 3:
            return const SettingsScreen();
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
