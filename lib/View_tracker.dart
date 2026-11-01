import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Records that a place / event / business page was opened, so the
/// Analytics and report pages can show "most viewed" and engagement.
///
/// Stored under:
///   analytics/views/<type>_<id>  -> { type, id, name, count, last }
///   analytics/daily/<yyyy-MM-dd> -> number of page views that day
///
/// It never throws: if the database rules don't allow the write (or the
/// network is down) the page simply isn't counted, and the visitor never
/// notices.
String dayKey(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

Future<void> trackView({
  required String type,
  required String id,
  required String name,
}) async {
  try {
    final db = FirebaseDatabase.instance;
    final ref = db.ref('analytics/views/${type}_$id');

    await ref.update({
      'type': type,
      'id': id,
      'name': name,
      'last': ServerValue.timestamp,
    });
    await ref.child('count').runTransaction((value) {
      final current = value is int ? value : 0;
      return Transaction.success(current + 1);
    });
    await db.ref('analytics/daily/${dayKey(DateTime.now())}').runTransaction(
      (value) {
        final current = value is int ? value : 0;
        return Transaction.success(current + 1);
      },
    );
  } catch (_) {
    // Tracking is best-effort only.
  }
}

/// Invisible widget: drop it anywhere in a page and it counts one view
/// when that page first appears.
class ViewTracker extends StatefulWidget {
  const ViewTracker({
    super.key,
    required this.type,
    required this.id,
    required this.name,
  });

  final String type;
  final String id;
  final String name;

  @override
  State<ViewTracker> createState() => _ViewTrackerState();
}

class _ViewTrackerState extends State<ViewTracker> {
  @override
  void initState() {
    super.initState();
    trackView(type: widget.type, id: widget.id, name: widget.name);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}