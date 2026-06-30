import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'viewer_persistence.dart';

/// Resolves viewer/room config from URL path, query params, or saved cookies.
class LaunchConfig {
  LaunchConfig._();

  static void apply() {
    if (!kIsWeb) return;

    final uri = Uri.base;

    final pathRoom = _roomFromPath(uri);
    if (pathRoom != null) {
      AppConfig.applyViewerLink(
        room: pathRoom,
        ntfy: uri.queryParameters['ntfy'],
      );
      return;
    }

    final queryRoom = uri.queryParameters['room'];
    final viewer = uri.queryParameters['viewer'];
    final ntfy = uri.queryParameters['ntfy'];

    if (viewer == '1' && queryRoom != null && queryRoom.isNotEmpty) {
      AppConfig.applyViewerLink(room: queryRoom, ntfy: ntfy);
      return;
    }

    final saved = ViewerPersistence.load();
    if (saved != null) {
      AppConfig.applyViewerLink(room: saved.room, ntfy: saved.ntfy);
      ViewerPersistence.replaceViewerUrl(saved.room, saved.ntfy);
      return;
    }

    if (queryRoom != null && queryRoom.isNotEmpty) {
      AppConfig.roomCode = queryRoom;
    }
    if (ntfy != null && ntfy.isNotEmpty) {
      AppConfig.ntfyTopic = ntfy;
    }
  }

  static String? _roomFromPath(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length == 2 && segments[0] == 'view') {
      return Uri.decodeComponent(segments[1]);
    }
    return null;
  }
}
