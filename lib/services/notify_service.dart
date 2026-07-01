import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/outcomes.dart';
import '../utils/entry_stats.dart';
import 'app_config.dart';

class NotifyService {
  static Future<bool> notifyPartner({
    required List<dynamic> allEntries,
    required String outcome,
    required int amount,
  }) async {
    if (!AppConfig.notifyPartner) return false;

    final topic = AppConfig.effectiveNtfyTopic.trim();
    if (topic.isEmpty) {
      debugPrint('ntfy: skipped — no topic (set room code or ntfy topic)');
      return false;
    }

    final today = countTodayEntries(allEntries);
    final total = allEntries.length;
    final emoji = Outcomes.emojiFor(outcome);

    final title = '$outcome - EUR $amount';
    final body =
        '$emoji Jopie\'s Catches | Vandaag: $today | Totaal: $total | waarde EUR $amount';

    try {
      // ntfy.sh allows browser CORS; direct POST is most reliable on web.
      final ok = kIsWeb
          ? await _sendDirectToNtfy(topic: topic, title: title, body: body) ||
              await _sendViaSameOriginProxy(
                topic: topic,
                title: title,
                body: body,
              )
          : await _sendDirectToNtfy(topic: topic, title: title, body: body);

      if (!ok) debugPrint('ntfy: delivery failed for topic $topic');
      return ok;
    } catch (e, stack) {
      debugPrint('ntfy notify failed: $e\n$stack');
      return false;
    }
  }

  static Future<bool> _sendViaSameOriginProxy({
    required String topic,
    required String title,
    required String body,
  }) async {
    final origin = Uri.base.origin;
    final uri = Uri.parse('$origin/api/ntfy/${Uri.encodeComponent(topic)}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Title': title,
          'Priority': 'high',
          'Tags': 'rotating_light',
        },
        body: body,
      );

      if (_looksLikeNtfyOk(response)) return true;
      debugPrint(
        'ntfy proxy bad response ${response.statusCode}: '
        '${response.body.substring(0, response.body.length.clamp(0, 120))}',
      );
    } catch (e) {
      debugPrint('ntfy same-origin proxy error: $e');
    }

    return false;
  }

  static Future<bool> _sendDirectToNtfy({
    required String topic,
    required String title,
    required String body,
  }) async {
    final uri = Uri.parse('https://ntfy.sh/${Uri.encodeComponent(topic)}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Title': title,
          'Priority': 'high',
          'Tags': 'rotating_light',
        },
        body: body,
      );
      if (_looksLikeNtfyOk(response)) return true;
    } catch (e) {
      debugPrint('ntfy direct headers error: $e');
    }

    try {
      final response = await http.post(uri, body: '$title\n$body');
      return _looksLikeNtfyOk(response);
    } catch (e) {
      debugPrint('ntfy direct body-only error: $e');
      return false;
    }
  }

  static bool _looksLikeNtfyOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) return false;
    final text = response.body.trimLeft();
    if (text.startsWith('<!') || text.startsWith('<html')) return false;
    return true;
  }
}
