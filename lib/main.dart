import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  await Hive.initFlutter();
  await Hive.openBox('entries');

  runApp(const CatchLogApp());
}

class CatchLogApp extends StatelessWidget {
  const CatchLogApp({super.key});

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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Color(0xFF0A84FF),
        backgroundColor: Color(0xFF1C1C1E),
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
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
            return const SettingsScreen();
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
