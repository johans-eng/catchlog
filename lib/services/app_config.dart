import 'dart:math';

import 'package:hive/hive.dart';

class AppConfig {
  static Box get _box => Hive.box('settings');

  static String get roomCode =>
      (_box.get('roomCode') as String?)?.trim() ?? '';

  static set roomCode(String value) => _box.put('roomCode', value.trim());

  static bool get isViewer => _box.get('isViewer', defaultValue: false) as bool;

  static set isViewer(bool value) => _box.put('isViewer', value);

  static String get ntfyTopic =>
      (_box.get('ntfyTopic') as String?)?.trim() ?? '';

  static set ntfyTopic(String value) => _box.put('ntfyTopic', value.trim());

  static bool get notifyPartner =>
      _box.get('notifyPartner', defaultValue: true) as bool;

  static set notifyPartner(bool value) => _box.put('notifyPartner', value);

  static bool get trustedDevice =>
      _box.get('trustedDevice', defaultValue: false) as bool;

  static set trustedDevice(bool value) => _box.put('trustedDevice', value);

  static bool get biometricEnabled =>
      _box.get('biometricEnabled', defaultValue: false) as bool;

  static set biometricEnabled(bool value) => _box.put('biometricEnabled', value);

  static String generateRoomCode() {
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static String shareLink(String baseUrl) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final params = <String, String>{
      'room': roomCode,
      'viewer': '1',
    };
    if (ntfyTopic.isNotEmpty) {
      params['ntfy'] = ntfyTopic;
    }
    return Uri.parse(base).replace(queryParameters: params).toString();
  }
}
