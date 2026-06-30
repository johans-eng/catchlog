import 'package:web/web.dart' as web;

import 'viewer_persistence_stub.dart';

class ViewerPersistence {
  static const _roomKey = 'jopie_room';
  static const _ntfyKey = 'jopie_ntfy';
  static const _viewerKey = 'jopie_viewer';

  static void save({required String room, String? ntfy}) {
    _setCookie(_viewerKey, '1');
    _setCookie(_roomKey, room);
    if (ntfy != null && ntfy.isNotEmpty) {
      _setCookie(_ntfyKey, ntfy);
    }
  }

  static ViewerSaved? load() {
    if (_getCookie(_viewerKey) != '1') return null;
    final room = _getCookie(_roomKey);
    if (room == null || room.isEmpty) return null;
    final ntfy = _getCookie(_ntfyKey);
    return ViewerSaved(room: room, ntfy: ntfy);
  }

  static void replaceViewerUrl(String room, String? ntfy) {
    final path = '/view/${Uri.encodeComponent(room)}';
    final uri = Uri(
      path: path,
      queryParameters:
          ntfy != null && ntfy.isNotEmpty ? {'ntfy': ntfy} : null,
    );
    web.window.history.replaceState(null, '', uri.toString());
  }

  static void _setCookie(String name, String value) {
    final encoded = Uri.encodeComponent(value);
    web.document.cookie =
        '$name=$encoded; path=/; max-age=31536000; SameSite=Lax';
  }

  static String? _getCookie(String name) {
    final raw = web.document.cookie;
    if (raw.isEmpty) return null;

    for (final part in raw.split(';')) {
      final trimmed = part.trim();
      if (!trimmed.startsWith('$name=')) continue;
      final value = trimmed.substring(name.length + 1);
      if (value.isEmpty) return null;
      return Uri.decodeComponent(value);
    }
    return null;
  }
}
