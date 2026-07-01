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
import 'services/launch_config.dart';
import 'utils/day_clock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  DayClock.instance;
  await Hive.initFlutter();
  await Hive.openBox('entries');
  await Hive.openBox('settings');
  if (kIsWeb) {
    LaunchConfig.apply();
  }
  await FirebaseService.init();

  runApp(const JopiesCatchesApp());
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
      builder: (context, child) {
        if (!kIsWeb || child == null) return child ?? const SizedBox.shrink();

        // Keep Flutter layout aligned with the iOS PWA viewport.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            padding: EdgeInsets.only(top: media.viewPadding.top),
          ),
          child: child,
        );
      },
      home: LockScreen(child: const RootPage()),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isViewer = AppConfig.isViewer;

    final tabs = isViewer
        ? const [
            (icon: Icons.home_outlined, active: Icons.home, label: 'Live'),
            (icon: Icons.bar_chart_outlined, active: Icons.bar_chart, label: 'Stats'),
            (icon: Icons.calendar_month_outlined, active: Icons.calendar_month, label: 'Calendar'),
            (icon: Icons.notifications_outlined, active: Icons.notifications, label: 'Meldingen'),
          ]
        : const [
            (icon: Icons.home_outlined, active: Icons.home, label: 'Home'),
            (icon: Icons.bar_chart_outlined, active: Icons.bar_chart, label: 'Stats'),
            (icon: Icons.calendar_month_outlined, active: Icons.calendar_month, label: 'Calendar'),
            (icon: Icons.settings_outlined, active: Icons.settings, label: 'Settings'),
          ];

    if (kIsWeb) {
      return Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            StatsScreen(),
            CalendarScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: const Color(0xFF1C1C1E),
            indicatorColor: const Color(0xFF0A84FF).withValues(alpha: 0.25),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                color: selected ? const Color(0xFF0A84FF) : const Color(0xFF8E8E93),
                decoration: TextDecoration.none,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected ? const Color(0xFF0A84FF) : const Color(0xFF8E8E93),
              );
            }),
          ),
          child: NavigationBar(
            height: 64,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              for (final tab in tabs)
                NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.active),
                  label: tab.label,
                ),
            ],
          ),
        ),
      );
    }

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        height: 56,
        iconSize: 26,
        activeColor: const Color(0xFF0A84FF),
        backgroundColor: const Color(0xFF1C1C1E),
        items: [
          for (final tab in tabs)
            BottomNavigationBarItem(
              icon: Icon(_cupertinoIcon(tab.icon)),
              label: tab.label,
            ),
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

  IconData _cupertinoIcon(IconData material) {
    return switch (material) {
      Icons.home_outlined || Icons.home => CupertinoIcons.home,
      Icons.bar_chart_outlined || Icons.bar_chart => CupertinoIcons.chart_bar,
      Icons.calendar_month_outlined || Icons.calendar_month => CupertinoIcons.calendar,
      Icons.notifications_outlined || Icons.notifications => CupertinoIcons.bell,
      Icons.settings_outlined || Icons.settings => CupertinoIcons.settings,
      _ => CupertinoIcons.circle,
    };
  }
}
