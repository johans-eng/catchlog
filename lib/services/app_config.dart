import 'dart:math';

import 'package:hive/hive.dart';

import 'viewer_persistence.dart';

class AppConfig {
  static Box get _box => Hive.box('settings');

  static String get roomCode =>
      (_box.get('roomCode') as String?)?.trim() ?? '';

  static set roomCode(String value) {
    final trimmed = value.trim();
    if (_isRoomCodeLocked && roomCode.isNotEmpty && trimmed != roomCode) return;
    _box.put('roomCode', trimmed);
  }

  static bool get isViewer => _box.get('isViewer', defaultValue: false) as bool;

  static set isViewer(bool value) {
    if (_isRoomCodeLocked && !value) return;
    _box.put('isViewer', value);
  }

  static bool get roomCodeLocked =>
      _box.get('roomCodeLocked', defaultValue: false) as bool;

  static set roomCodeLocked(bool value) => _box.put('roomCodeLocked', value);

  static bool get _isRoomCodeLocked =>
      roomCodeLocked || (isViewer && roomCode.isNotEmpty);

  static String get ntfyTopic =>
      (_box.get('ntfyTopic') as String?)?.trim() ?? '';

  /// Topic used for sends/subscribe — falls back to jopie-{roomCode}.
  static String get effectiveNtfyTopic {
    final topic = ntfyTopic;
    if (topic.isNotEmpty) return topic;
    final room = roomCode;
    if (room.isNotEmpty) return 'jopie-$room';
    return '';
  }

  static set ntfyTopic(String value) {
    final trimmed = value.trim();
    if (_isRoomCodeLocked && ntfyTopic.isNotEmpty && trimmed != ntfyTopic) {
      return;
    }
    _box.put('ntfyTopic', trimmed);
  }

  static bool get notifyPartner =>
      _box.get('notifyPartner', defaultValue: true) as bool;

  static set notifyPartner(bool value) => _box.put('notifyPartner', value);

  static bool get trustedDevice =>
      _box.get('trustedDevice', defaultValue: false) as bool;

  static set trustedDevice(bool value) => _box.put('trustedDevice', value);

  static bool get biometricEnabled =>
      _box.get('biometricEnabled', defaultValue: false) as bool;

  static set biometricEnabled(bool value) => _box.put('biometricEnabled', value);

  /// Called when partner opens the shared viewer link.
  static void applyViewerLink({
    required String room,
    String? ntfy,
  }) {
    roomCodeLocked = true;
    roomCode = room;
    isViewer = true;
    if (ntfy != null && ntfy.isNotEmpty) {
      ntfyTopic = ntfy;
    }
    ViewerPersistence.save(room: room, ntfy: ntfy);
    ViewerPersistence.replaceViewerUrl(room, ntfy);
  }

  static String generateRoomCode() {
    if (_isRoomCodeLocked) {
      throw StateError('Deelcode is vergrendeld');
    }
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static String shareLink(String baseUrl) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final path = '$base/view/${Uri.encodeComponent(roomCode)}';
    final topic = effectiveNtfyTopic;
    if (topic.isEmpty) return path;
    return Uri.parse(path).replace(queryParameters: {'ntfy': topic}).toString();
  }
}
