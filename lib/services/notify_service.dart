import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/outcomes.dart';
import '../utils/entry_stats.dart';
import 'app_config.dart';

class NotifyService {
  static Future<void> notifyPartner({
    required List<dynamic> allEntries,
    required String outcome,
    required int amount,
  }) async {
    if (!AppConfig.notifyPartner) return;

    final topic = AppConfig.ntfyTopic.trim();
    if (topic.isEmpty) {
      debugPrint('ntfy: skipped — no topic configured');
      return;
    }

    final today = countTodayEntries(allEntries);
    final total = allEntries.length;
    final emoji = Outcomes.emojiFor(outcome);

    // Keep headers ASCII-only; emoji goes in the message body.
    final title = '$outcome - EUR $amount';
    final body =
        '$emoji Jopie\'s Catches | Vandaag: $today | Totaal: $total | waarde EUR $amount';

    try {
      final ok = kIsWeb
          ? await _sendViaNetlifyProxy(
              topic: topic,
              title: title,
              body: body,
            )
          : await _sendDirectToNtfy(
              topic: topic,
              title: title,
              body: body,
            );

      if (!ok) {
        debugPrint('ntfy: delivery failed for topic $topic');
      }
    } catch (e, stack) {
      debugPrint('ntfy notify failed: $e\n$stack');
    }
  }

  /// Browser/PWA cannot set ntfy headers cross-origin (CORS preflight).
  static Future<bool> _sendViaNetlifyProxy({
    required String topic,
    required String title,
    required String body,
  }) async {
    final origin = Uri.base.origin;
    final proxy = Uri.parse('$origin/.netlify/functions/ntfy-notify');

    final response = await http.post(
      proxy,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic,
        'title': title,
        'body': body,
        'tags': 'rotating_light',
        'priority': 'high',
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    debugPrint('ntfy proxy ${response.statusCode}: ${response.body}');

    // Local dev / missing function — fall back to simple body-only POST.
    return _sendDirectToNtfy(
      topic: topic,
      title: title,
      body: body,
      headersInBodyOnly: true,
    );
  }

  static Future<bool> _sendDirectToNtfy({
    required String topic,
    required String title,
    required String body,
    bool headersInBodyOnly = false,
  }) async {
    final uri = Uri.parse('https://ntfy.sh/${Uri.encodeComponent(topic)}');

    if (headersInBodyOnly) {
      final response = await http.post(uri, body: '$title\n$body');
      return response.statusCode >= 200 && response.statusCode < 300;
    }

    final response = await http.post(
      uri,
      headers: {
        'Title': title,
        'Priority': 'high',
        'Tags': 'rotating_light',
      },
      body: body,
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
