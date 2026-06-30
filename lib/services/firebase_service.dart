import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'app_config.dart';

class FirebaseService {
  static bool _ready = false;

  static bool get isReady => _ready;

  static Future<void> init() async {
    if (_ready || !DefaultFirebaseOptions.isConfigured) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _ready = true;
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
  }

  static CollectionReference<Map<String, dynamic>>? entriesRef() {
    if (!_ready) return null;
    final code = AppConfig.roomCode;
    if (code.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('rooms')
        .doc(code)
        .collection('entries');
  }

  static Stream<List<Map<String, dynamic>>> watchEntries() {
    final ref = entriesRef();
    if (ref == null) return const Stream.empty();
    return ref.orderBy('time').snapshots().map(
          (snap) => snap.docs.map((doc) => doc.data()).toList(),
        );
  }

  static Future<void> addEntry(Map<String, dynamic> entry) async {
    final ref = entriesRef();
    if (ref == null) {
      throw StateError('Firebase niet klaar of geen deelcode ingesteld');
    }
    await ref.add(entry);
  }
}
