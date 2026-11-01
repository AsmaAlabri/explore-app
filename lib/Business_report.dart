import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'business.dart';
import 'charts.dart';
import 'l10n/app_strings.dart';

/// Business Owner report: how many people viewed each of the owner's
/// listings and what visitors said about them in feedback.
class BusinessReportPage extends StatefulWidget {
  const BusinessReportPage({super.key});

  @override
  State<BusinessReportPage> createState() => _BusinessReportPageState();
}

class _Comment {
  _Comment(this.text, this.rating, this.time);

  final String text;
  final int rating;
  final int time;
}

class _BizStat {
  _BizStat(this.business);

  final Business business;
  int views = 0;
  int feedback = 0;
  int ratingTotal = 0;
  int rated = 0;
  final ratingCounts = List<int>.filled(5, 0);
  final comments = <_Comment>[];

  double get average => rated == 0 ? 0 : ratingTotal / rated;
}

class _ReportData {
  final stats = <_BizStat>[];
  bool feedbackDenied = false;
  bool viewsDenied = false;
  final viewsPerDay = <ChartPoint>[];
}

class _BusinessReportPageState extends State<BusinessReportPage> {
  late Future<_ReportData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _reload() => setState(() => _future = _load());

  int _asInt(dynamic raw) =>
      raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;

  Future<_ReportData> _load() async {
    final data = _ReportData();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return data;

    final db = FirebaseDatabase.instance;

    // The owner's businesses.
    final bizSnap = await db.ref('businesses').get();
    final bizValue = bizSnap.value;
    if (bizValue is Map) {
      bizValue.forEach((key, raw) {
        if (raw is! Map) return;
        final b = Business.fromMap(key.toString(), raw);
        if (b.ownerId == uid) data.stats.add(_BizStat(b));
      });
    }
    data.stats.sort((a, b) => a.business.name.compareTo(b.business.name));

    // Views per listing.
    try {
      final views = await db.ref('analytics/views').get();
      final v = views.value;
      if (v is Map) {
        for (final s in data.stats) {
          final entry = v['business_${s.business.id}'];
          if (entry is Map) s.views = _asInt(entry['count']);
        }
      }
    } catch (_) {
      data.viewsDenied = true;
    }

    // Feedback matched by business name.
    try {
      final fb = await db.ref('feedback').get();
      final f = fb.value;
      if (f is Map) {
        for (final raw in f.values) {
          if (raw is! Map) continue;
          final place = raw['place']?.toString().trim().toLowerCase() ?? '';
          if (place.isEmpty) continue;
          for (final s in data.stats) {
            if (place != s.business.name.trim().toLowerCase()) continue;
            s.feedback++;
            final rating = _asInt(raw['rating']).clamp(0, 5).toInt();
            if (rating >= 1) {
              s.ratingCounts[rating - 1]++;
              s.ratingTotal += rating;
              s.rated++;
            }
            final text = raw['comment']?.toString().trim() ?? '';
            if (text.isNotEmpty) {
              s.comments.add(_Comment(text, rating, _asInt(raw['timestamp'])));
            }
          }
        }
        for (final s in data.stats) {
          s.comments.sort((a, b) => b.time.compareTo(a.time));
        }
      }
    } catch (_) {
      data.feedbackDenied = true;
    }

    return data;
  }

  String _reportText(_ReportData d) {
    final b = StringBuffer()
      ..writeln(tr('c_report_share_title'))
      ..writeln(tr('c_report_generated')
          .replaceAll('{date}', DateTime.now().toString().substring(0, 10)));
    for (final s in d.stats) {
      b
        ..writeln()
        ..writeln(s.business.name)
        ..writeln(tr('c_report_views_line').replaceAll('{n}', '${s.views}'))
        ..writeln(tr('c_report_feedback_line').replaceAll('{n}', '${s.feedback}') +
            (s.rated == 0
                ? ''
                : tr('c_report_average')
                    .replaceAll('{avg}', s.average.toStringAsFixed(1))));
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('c_business_report')),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: tr('c_refresh'),
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<_ReportData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${tr('c_report_load_error')}\n${snapshot.error ?? ''}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _content(snapshot.data!);
        },
      ),
    );
  }

  Widget _content(_ReportData d) {
    if (d.stats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            tr('c_report_no_business'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final totalViews = d.stats.fold<int>(0, (s, e) => s + e.views);
    final totalFeedback = d.stats.fold<int>(0, (s, e) => s + e.feedback);
    final ratedTotal = d.stats.fold<int>(0, (s, e) => s + e.rated);
    final ratingSum = d.stats.fold<int>(0, (s, e) => s + e.ratingTotal);
    final overall = ratedTotal == 0 ? 0.0 : ratingSum / ratedTotal;
    final maxViews = d.stats.fold<int>(0, (m, e) => e.views > m ? e.views : m);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            if (d.feedbackDenied || d.viewsDenied)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tr('c_report_no_permission'),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: [
                StatTile(
                  icon: Icons.visibility,
                  label: tr('c_views'),
                  value: '$totalViews',
                  color: Colors.brown[700]!,
                ),
                StatTile(
                  icon: Icons.reviews,
                  label: tr('feedback'),
                  value: '$totalFeedback',
                  color: Colors.brown[500]!,
                ),
                StatTile(
                  icon: Icons.star,
                  label: tr('c_rating'),
                  value: overall == 0 ? '-' : overall.toStringAsFixed(1),
                  color: Colors.amber[800]!,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ChartCard(
              title: tr('c_views_per_listing'),
              child: Column(
                children: [
                  for (final s in d.stats)
                    BarRow(
                      label: s.business.name,
                      value: s.views,
                      max: maxViews,
                      color: Colors.brown[600]!,
                      labelWidth: 120,
                    ),
                ],
              ),
            ),
            for (final s in d.stats)
              ChartCard(
                title: s.business.name,
                subtitle: businessStatusLabel(s.business.status),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, size: 18, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          s.rated == 0 ? '-' : s.average.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          tr('c_feedback_views_line')
                              .replaceAll('{f}', '${s.feedback}')
                              .replaceAll('{v}', '${s.views}'),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (s.rated == 0)
                      ChartEmptyNote(tr('c_no_ratings'))
                    else
                      for (var stars = 5; stars >= 1; stars--)
                        BarRow(
                          label: stars == 1
                              ? tr('c_one_star')
                              : tr('c_n_stars').replaceAll('{n}', '$stars'),
                          value: s.ratingCounts[stars - 1],
                          max: s.ratingCounts.reduce((a, b) => a > b ? a : b),
                          color: Colors.amber[700]!,
                        ),
                    if (s.comments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        tr('c_recent_comments'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      for (final c in s.comments.take(3))
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '"${c.text}"'
                            '${c.rating > 0 ? '  (${c.rating}/5)' : ''}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.ios_share),
                label: Text(tr('c_share_report')),
                onPressed: () => Share.share(_reportText(d)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}