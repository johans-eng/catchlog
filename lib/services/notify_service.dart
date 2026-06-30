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

    final topic = AppConfig.ntfyTopic;
    if (topic.isEmpty) return;

    final today = countTodayEntries(allEntries);
    final total = allEntries.length;
    final emoji = Outcomes.emojiFor(outcome);

    final uri = Uri.parse('https://ntfy.sh/$topic');
    try {
      await http.post(
        uri,
        headers: {
          'Title': '$emoji $outcome — €$amount',
          'Priority': 'high',
          'Tags': 'rotating_light',
        },
        body:
            "Jopie's Catches | Vandaag: $today | Totaal: $total | waarde €$amount",
      );
    } catch (_) {
      // Notification failure should not block logging.
    }
  }
}
