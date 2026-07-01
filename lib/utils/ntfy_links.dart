import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ntfy_open_stub.dart'
    if (dart.library.html) 'ntfy_open_web.dart' as ntfy_open;

enum NtfySubscribeMode { appDeepLink, iosManual, failed }

class NtfySubscribeResult {
  const NtfySubscribeResult({
    required this.mode,
    required this.topic,
  });

  final NtfySubscribeMode mode;
  final String topic;
}

class NtfyLinks {
  static const _host = 'ntfy.sh';
  static const appStoreUri = 'https://apps.apple.com/app/ntfy/id1625396347';

  static Uri subscribeUri(String topic) =>
      Uri.parse('https://$_host/${Uri.encodeComponent(topic)}');

  static Uri appSubscribeUri(String topic) {
    return Uri(
      scheme: 'ntfy',
      host: _host,
      pathSegments: [topic],
      queryParameters: const {'display': 'Jopies Catches'},
    );
  }

  static Future<NtfySubscribeResult> openSubscribe(String topic) async {
    if (topic.isEmpty) {
      return NtfySubscribeResult(mode: NtfySubscribeMode.failed, topic: topic);
    }

    if (kIsWeb && ntfy_open.isIosWeb) {
      await Clipboard.setData(ClipboardData(text: topic));
      return NtfySubscribeResult(mode: NtfySubscribeMode.iosManual, topic: topic);
    }

    final appUri = appSubscribeUri(topic);

    if (kIsWeb) {
      ntfy_open.launchDeepLink(appUri.toString());
      return NtfySubscribeResult(mode: NtfySubscribeMode.appDeepLink, topic: topic);
    }

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return NtfySubscribeResult(mode: NtfySubscribeMode.appDeepLink, topic: topic);
    }

    final webUri = subscribeUri(topic);
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return NtfySubscribeResult(mode: NtfySubscribeMode.appDeepLink, topic: topic);
    }

    return NtfySubscribeResult(mode: NtfySubscribeMode.failed, topic: topic);
  }

  static Future<bool> openAppStore() async {
    final uri = Uri.parse(appStoreUri);
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
