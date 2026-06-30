import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_branding.dart';
import '../firebase_options.dart';
import '../services/app_config.dart';
import '../services/firebase_service.dart';
import '../widgets/app_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController roomController;
  late final TextEditingController ntfyController;

  @override
  void initState() {
    super.initState();
    roomController = TextEditingController(text: AppConfig.roomCode);
    ntfyController = TextEditingController(text: AppConfig.ntfyTopic);
  }

  @override
  void dispose() {
    roomController.dispose();
    ntfyController.dispose();
    super.dispose();
  }

  String get _baseUrl {
    if (kIsWeb) return Uri.base.origin;
    return 'https://jopies-catches.netlify.app';
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('entries');
    final cloudReady = FirebaseService.isReady;

    return AppScaffold(
      showGlow: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenTitle(
                title: 'Settings',
                subtitle: "Beheer je ${AppBranding.name} data",
              ),
              const SizedBox(height: 24),
              _section('DEEL MET PARTNER'),
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!cloudReady) ...[
                      const Text(
                        'Firebase nog niet gekoppeld. Voeg je Firebase keys toe in Netlify (zie onder) om live delen te activeren.',
                        style: TextStyle(
                          color: Color(0xFFFF9F0A),
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'Deelcode',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: roomController,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2C2C2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'bijv. jopie123',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      onChanged: (v) => AppConfig.roomCode = v,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              final code = AppConfig.generateRoomCode();
                              final topic = 'jopie-$code';
                              roomController.text = code;
                              ntfyController.text = topic;
                              AppConfig.roomCode = code;
                              AppConfig.ntfyTopic = topic;
                              setState(() {});
                            },
                            child: const Text('Nieuwe code'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: AppConfig.roomCode.isEmpty
                                ? null
                                : () => _copyLink(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A84FF),
                            ),
                            child: const Text('Kopieer link'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Stuur de link naar je vriendin. Zij ziet live hoeveel vangsten je hebt.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _section('NOTIFICATIES (GRATIS)'),
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Stuur melding bij nieuwe dief',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      value: AppConfig.notifyPartner,
                      activeThumbColor: const Color(0xFF0A84FF),
                      onChanged: (v) {
                        setState(() => AppConfig.notifyPartner = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ntfy topic (geheim woord)',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ntfyController,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2C2C2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'jopie-catches-geheim',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      onChanged: (v) => AppConfig.ntfyTopic = v,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Zij installeert de gratis ntfy app en abonneert op hetzelfde topic. Dan krijgt ze een pushmelding op haar telefoon.',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _section('DATA'),
              AppCard(
                margin: EdgeInsets.zero,
                child: ValueListenableBuilder(
                  valueListenable: box.listenable(),
                  builder: (context, _, __) {
                    return Text(
                      '${box.length} lokale entries opgeslagen',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (DefaultFirebaseOptions.isConfigured)
                const Text(
                  'Firebase: gekoppeld',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF30D158),
                    decoration: TextDecoration.none,
                  ),
                )
              else
                const Text(
                  'Firebase: niet gekoppeld (nodig voor live delen)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              const SizedBox(height: 24),
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
                    'Wis lokale data',
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

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  void _copyLink(BuildContext context) {
    final link = AppConfig.shareLink(_baseUrl);
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link gekopieerd: $link')),
    );
  }

  void _confirmClear(BuildContext context, Box box) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Lokale data wissen?',
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
        content: const Text(
          'Dit wist alleen data op dit apparaat. Gedeelde cloud data blijft staan.',
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
