import 'package:flutter/material.dart';

import '../constants/outcomes.dart';
import '../services/entry_store.dart';
import '../services/firebase_service.dart';
import '../services/notify_service.dart';
import 'success_notification.dart';

Future<void> showAddEntrySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AddEntrySheet(),
  );
}

class AddEntrySheet extends StatefulWidget {
  const AddEntrySheet({super.key});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final valueController = TextEditingController();
  final store = EntryStore.instance;
  String selectedOutcome = Outcomes.all.first;

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final value = int.tryParse(valueController.text.trim());
    final messenger = ScaffoldMessenger.of(context);

    if (value == null || value <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Voer een geldige waarde in (€)')),
      );
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);

    try {
      await store.addEntry(amount: value, outcome: selectedOutcome);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Opgeslagen lokaal, maar cloud sync mislukt. '
            'Controleer je deelcode in Settings. ($e)',
          ),
        ),
      );
      return;
    }

    final entries = store.usesCloud
        ? await _fetchCloudEntries()
        : store.localEntries;

    await NotifyService.notifyPartner(
      allEntries: entries,
      outcome: selectedOutcome,
      amount: value,
    );

    if (!context.mounted) return;
    Navigator.pop(context);
    showCatchSuccessNotification(overlay);
  }

  Future<List<Map<String, dynamic>>> _fetchCloudEntries() async {
    final ref = FirebaseService.entriesRef();
    if (ref == null) return store.localEntries;
    final snap = await ref.orderBy('time').get();
    return snap.docs.map((d) => d.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nieuwe dief',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Waarde van gestolen goederen (€)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                hintText: 'Waarde in euro',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  decoration: TextDecoration.none,
                ),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.euro, color: Color(0xFF0A84FF)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Uitkomst',
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedOutcome,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2C2C2E),
                  icon: const Icon(Icons.expand_more, color: Color(0xFF0A84FF)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                  items: Outcomes.all
                      .map(
                        (o) => DropdownMenuItem(
                          value: o,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Outcomes.colorFor(o),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                o,
                                style: const TextStyle(
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedOutcome = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A84FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Opslaan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
