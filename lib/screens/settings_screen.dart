import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_branding.dart';
import '../firebase_options.dart';
import '../services/app_config.dart';
import '../services/firebase_service.dart';
import '../utils/ntfy_links.dart';
import '../widgets/app_background.dart';
import '../widgets/app_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController roomController;
  late final TextEditingController ntfyController;

  bool get _isViewer => AppConfig.isViewer;

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
                title: _isViewer ? 'Meldingen' : 'Settings',
                subtitle: _isViewer
                    ? 'Ontvang pushmeldingen bij nieuwe vangsten'
                    : "Beheer je ${AppBranding.name} data",
              ),
              const SizedBox(height: 24),
              if (_isViewer) ...[
                _section('GEKOPPELD'),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      SelectableText(
                        AppConfig.roomCode.isEmpty
                            ? 'Geen code — open de gedeelde link opnieuw'
                            : AppConfig.roomCode,
                        style: const TextStyle(
                          color: Color(0xFF0A84FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vastgezet via jouw link. Add to Home Screen om te bewaren.',
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
                _ntfySection(showSubscribeButton: true),
              ] else ...[
                _section('DEEL MET PARTNER'),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!cloudReady) ...[
                        const Text(
                          'Firebase nog niet gekoppeld. Voeg je Firebase keys toe in Netlify om live delen te activeren.',
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
                        readOnly: AppConfig.roomCodeLocked,
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
                          suffixIcon: AppConfig.roomCodeLocked
                              ? const Icon(Icons.lock, color: Color(0xFF8E8E93))
                              : null,
                        ),
                        onChanged: AppConfig.roomCodeLocked
                            ? null
                            : (v) => AppConfig.roomCode = v,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppSecondaryButton(
                              onPressed: AppConfig.roomCodeLocked
                                  ? null
                                  : () {
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
                            child: AppPrimaryButton(
                              onPressed: AppConfig.roomCode.isEmpty
                                  ? null
                                  : () => _copyLink(context),
                              child: const Text(
                                'Kopieer link',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.none,
                                ),
                              ),
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
                _ntfySection(showSubscribeButton: false),
                const SizedBox(height: 16),
                _section('BEVEILIGING'),
                AppCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSwitchRow(
                        value: AppConfig.trustedDevice,
                        onChanged: (v) {
                          setState(() => AppConfig.trustedDevice = v);
                        },
                        title: const Text(
                          'Onthoud dit apparaat (PIN overslaan)',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppSecondaryButton(
                        onPressed: () {
                          AppConfig.trustedDevice = false;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vertrouwd apparaat gereset'),
                            ),
                          );
                        },
                        child: const Text('Reset vertrouwd apparaat'),
                      ),
                      if (kIsWeb)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Face ID werkt niet in de browser-PWA. In een native app wel.',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
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
                  child: AppPrimaryButton(
                    color: const Color(0xFFFF453A),
                    onPressed: () => _confirmClear(context, box),
                    child: const Text(
                      'Wis lokale data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _ntfySection({required bool showSubscribeButton}) {
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isViewer)
            AppSwitchRow(
              value: AppConfig.notifyPartner,
              onChanged: (v) {
                setState(() => AppConfig.notifyPartner = v);
              },
              title: const Text(
                'Stuur melding bij nieuwe dief',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          if (!_isViewer) const SizedBox(height: 8),
          const Text(
            'ntfy topic',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          if (_isViewer)
            SelectableText(
              AppConfig.ntfyTopic.isEmpty
                  ? 'Geen topic — open de gedeelde link opnieuw'
                  : AppConfig.ntfyTopic,
              style: const TextStyle(
                color: Color(0xFF0A84FF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            )
          else
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
          Text(
            _isViewer
                ? 'Installeer de gratis ntfy app en abonneer op het topic hieronder.'
                : 'Zij abonneert op hetzelfde topic in de ntfy app.',
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
          if (showSubscribeButton && AppConfig.ntfyTopic.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppPrimaryButton(
              onPressed: () => _openNtfy(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_active_outlined, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Abonneren in ntfy',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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

  Future<void> _openNtfy(BuildContext context) async {
    final topic = AppConfig.ntfyTopic;
    if (topic.isEmpty) return;

    final ok = await NtfyLinks.openSubscribe(topic);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'ntfy geopend — bevestig abonnement in de app'
              : 'Kon ntfy niet openen. Installeer ntfy en voer topic handmatig in: $topic',
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
