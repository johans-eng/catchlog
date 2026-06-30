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
      return FirebaseService.watchEntries();
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

    if (usesCloud) {
      await FirebaseService.addEntry(entry);
    } else {
      await _local.add(entry);
    }
  }

  int todayCountFrom(List<Map<String, dynamic>> entries) {
    return countTodayEntries(entries);
  }

  int totalCountFrom(List<Map<String, dynamic>> entries) => entries.length;
}
