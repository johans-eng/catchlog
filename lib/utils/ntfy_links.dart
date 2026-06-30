import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class NtfyLinks {
  static Uri subscribeUri(String topic) => Uri.parse('https://ntfy.sh/$topic');

  static Future<bool> openSubscribe(String topic) async {
    if (topic.isEmpty) return false;

    final webUri = subscribeUri(topic);
    if (await canLaunchUrl(webUri)) {
      return launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    if (!kIsWeb) {
      final appUri = Uri.parse('ntfy://$topic');
      if (await canLaunchUrl(appUri)) {
        return launchUrl(appUri, mode: LaunchMode.externalApplication);
      }
    }

    return false;
  }
}
