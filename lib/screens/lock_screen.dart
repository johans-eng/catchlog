import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../constants/app_branding.dart';
import '../constants/app_security.dart';
import '../services/app_config.dart';
import '../widgets/jopies_logo.dart';
import '../widgets/app_background.dart';
import '../widgets/app_button.dart';

class LockScreen extends StatefulWidget {
  final Widget child;

  const LockScreen({super.key, required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final controller = TextEditingController();
  final auth = LocalAuthentication();
  bool unlocked = false;
  bool rememberDevice = false;
  bool biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    if (AppConfig.isViewer || AppConfig.trustedDevice) {
      unlocked = true;
    }
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    if (kIsWeb) return;
    try {
      final canCheck = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();
      if (mounted) {
        setState(() => biometricsAvailable = canCheck && supported);
      }
      if (AppConfig.biometricEnabled && biometricsAvailable && !unlocked) {
        await _unlockWithBiometrics();
      }
    } catch (_) {}
  }

  Future<void> _unlockWithBiometrics() async {
    try {
      final ok = await auth.authenticate(
        localizedReason: 'Ontgrendel ${AppBranding.name}',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (ok && mounted) setState(() => unlocked = true);
    } catch (_) {}
  }

  void check() {
    if (controller.text == AppSecurity.pin) {
      if (rememberDevice) AppConfig.trustedDevice = true;
      setState(() => unlocked = true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppConfig.isViewer) return widget.child;
    if (unlocked) return widget.child;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    JopiesLogo(size: 72),
                    const SizedBox(height: 16),
                    const Text(
                      AppBranding.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Voer PIN in',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8E8E93),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: controller,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 8,
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1C1C1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => check(),
                    ),
                    const SizedBox(height: 16),
                    AppTapRow(
                      value: rememberDevice,
                      onChanged: (v) => setState(() => rememberDevice = v),
                      title: const Text(
                        'Onthoud op dit apparaat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppPrimaryButton(
                      onPressed: check,
                      child: const Text(
                        'Unlock',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    if (biometricsAvailable) ...[
                      const SizedBox(height: 12),
                      AppSecondaryButton(
                        onPressed: _unlockWithBiometrics,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.face),
                            SizedBox(width: 8),
                            Text('Face ID / Touch ID'),
                          ],
                        ),
                      ),
                    ],
                    if (kIsWeb) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Face ID werkt niet in de browser-PWA. Gebruik "Onthoud op dit apparaat" na je PIN.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
