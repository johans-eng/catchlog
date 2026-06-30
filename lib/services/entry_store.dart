import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/entry_stats.dart';
import 'app_config.dart';
import 'firebase_service.dart';

class EntryStore {
  EntryStore._();

  static final EntryStore instance = EntryStore._();

  Box get _local => Hive.box('entries');

  bool get usesCloud =>
      FirebaseService.isReady && AppConfig.roomCode.isNotEmpty;

  List<Map<String, dynamic>> get localEntries => _local.values
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();

  Stream<List<Map<String, dynamic>>> watchEntries() {
    if (usesCloud) {
      return FirebaseService.watchEntries().map(_mergeWithLocal);
    }
    return Stream.value(localEntries);
  }

  ValueListenable<Box> get localListenable => _local.listenable();

  Future<void> addEntry({
    required int amount,
    required String outcome,
  }) async {
    final entry = {
      'amount': amount,
      'outcome': outcome,
      'time': DateTime.now().millisecondsSinceEpoch,
    };

    await _local.add(entry);

    if (!usesCloud) return;

    try {
      await FirebaseService.addEntry(entry);
    } catch (e, stack) {
      debugPrint('Firebase sync failed: $e\n$stack');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _mergeWithLocal(
    List<Map<String, dynamic>> cloud,
  ) {
    final merged = [...cloud];
    for (final local in localEntries) {
      final exists = merged.any((e) => _sameEntry(e, local));
      if (!exists) merged.add(local);
    }
    merged.sort(
      (a, b) => ((a['time'] as int?) ?? 0).compareTo((b['time'] as int?) ?? 0),
    );
    return merged;
  }

  bool _sameEntry(Map<String, dynamic> a, Map<String, dynamic> b) {
    return a['time'] == b['time'] &&
        a['amount'] == b['amount'] &&
        a['outcome'] == b['outcome'];
  }

  int todayCountFrom(List<Map<String, dynamic>> entries) {
    return countTodayEntries(entries);
  }

  int totalCountFrom(List<Map<String, dynamic>> entries) => entries.length;
}
