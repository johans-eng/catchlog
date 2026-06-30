import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies listeners when the local calendar day changes (at midnight).
class DayClock extends ChangeNotifier {
  DayClock._() {
    _scheduleNextMidnight();
  }

  static final DayClock instance = DayClock._();

  Timer? _timer;

  void _scheduleNextMidnight() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(nextMidnight.difference(now), () {
      notifyListeners();
      _scheduleNextMidnight();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
