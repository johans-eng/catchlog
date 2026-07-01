import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ntfy_open_stub.dart'
    if (dart.library.html) 'ntfy_open_web.dart' as ntfy_open;

class NtfyLinks {
  static const _host = 'ntfy.sh';

  static Uri subscribeUri(String topic) =>
      Uri.parse('https://$_host/${Uri.encodeComponent(topic)}');

  /// Opens the native ntfy app when installed (Android + recent iOS).
  static Uri appSubscribeUri(String topic) {
    return Uri(
      scheme: 'ntfy',
      host: _host,
      pathSegments: [topic],
      queryParameters: const {'display': 'Jopies Catches'},
    );
  }

  static Future<bool> openSubscribe(String topic) async {
    if (topic.isEmpty) return false;

    final appUri = appSubscribeUri(topic);

    if (kIsWeb) {
      ntfy_open.launchDeepLink(appUri.toString());
      return true;
    }

    if (await canLaunchUrl(appUri)) {
      return launchUrl(appUri, mode: LaunchMode.externalApplication);
    }

    final webUri = subscribeUri(topic);
    if (await canLaunchUrl(webUri)) {
      return launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    return false;
  }
}
