import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_branding.dart';
import '../widgets/app_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('entries');

    return AppScaffold(
      showGlow: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenTitle(
                title: 'Settings',
                subtitle: "Beheer je ${AppBranding.name} data",
              ),
              const SizedBox(height: 32),
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATA',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: box.listenable(),
                      builder: (context, _, __) {
                        return Text(
                          '${box.length} entries opgeslagen',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _confirmClear(context, box),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF453A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Wis alle data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, Box box) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Alles wissen?',
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
        content: const Text(
          'Dit verwijdert alle gelogde dieven permanent.',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuleer',
              style: TextStyle(decoration: TextDecoration.none),
            ),
          ),
          TextButton(
            onPressed: () {
              box.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Wis',
              style: TextStyle(
                color: Color(0xFFFF453A),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
