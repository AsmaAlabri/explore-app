import 'package:firebase_database/firebase_database.dart';

import 'app_settings.dart';
import 'l10n/app_strings.dart';

/// An announcement posted by the admin (event update, new place, news).
/// Stored in the 'announcements' Firebase node and shown to everyone on
/// the Notifications page.
///   kind 'event'  -> event updates (can be switched off with the
///                    "Event updates" toggle on the Notifications page)
///   kind 'update' -> general news about the app / Oman
class Announcement {
  const Announcement({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.kind,
    required this.createdAt,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final String kind;
  final int createdAt;

  bool get isEvent => kind == 'event';

  String get title {
    if (AppSettings.instance.isArabic && titleAr.isNotEmpty) return titleAr;
    return titleEn;
  }

  String get body {
    if (AppSettings.instance.isArabic && bodyAr.isNotEmpty) return bodyAr;
    return bodyEn;
  }

  static Announcement fromMap(String id, Map<dynamic, dynamic> map) {
    final created = map['createdAt'];
    return Announcement(
      id: id,
      titleEn: map['title_en']?.toString() ?? '',
      titleAr: map['title_ar']?.toString() ?? '',
      bodyEn: map['body_en']?.toString() ?? '',
      bodyAr: map['body_ar']?.toString() ?? '',
      kind: map['kind']?.toString() ?? 'update',
      createdAt: created is int ? created : int.tryParse('$created') ?? 0,
    );
  }
}

final announcementsRef = FirebaseDatabase.instance.ref('announcements');

/// Reads the snapshot value of the announcements node into a list,
/// newest first.
List<Announcement> parseAnnouncements(Object? value) {
  final list = <Announcement>[];
  if (value is Map) {
    for (final entry in value.entries) {
      if (entry.value is Map) {
        list.add(Announcement.fromMap(entry.key.toString(), entry.value as Map));
      }
    }
  }
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
}

String timeAgo(int millis, {required bool arabic}) {
  if (millis <= 0) return '';
  final diff = DateTime.now().difference(
    DateTime.fromMillisecondsSinceEpoch(millis),
  );
  String n(String key, int v) => tr(key).replaceAll('{n}', '$v');
  if (diff.inMinutes < 1) return tr('d_ann_just_now');
  if (diff.inMinutes < 60) return n('d_ann_min_ago', diff.inMinutes);
  if (diff.inHours < 24) return n('d_ann_h_ago', diff.inHours);
  if (diff.inDays < 30) return n('d_ann_d_ago', diff.inDays);
  final d = DateTime.fromMillisecondsSinceEpoch(millis);
  return '${d.day}/${d.month}/${d.year}';
}