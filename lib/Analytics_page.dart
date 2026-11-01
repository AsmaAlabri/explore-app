import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'business.dart';
import 'charts.dart';
import 'l10n/app_strings.dart';
import 'view_tracker.dart';

/// Admin screen: reports and charts about how the app is used.
///  - activity (page views per day, sign-ups per day)
///  - users and businesses breakdowns
///  - most viewed places and businesses
///  - event engagement (views + feedback per event)
///  - feedback summary (ratings, top rated places, tags, recent comments)
/// Everything is calculated from live Firebase data when the page opens
/// (use the refresh button to reload).
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _Viewed {
  _Viewed(this.name, this.count);

  final String name;
  final int count;
}

class _PlaceRating {
  _PlaceRating(this.place);

  final String place;
  int total = 0;
  int count = 0;

  double get average => count == 0 ? 0 : total / count;
}

class _EventStat {
  _EventStat(this.name);

  final String name;
  int views = 0;
  int feedback = 0;
  int ratingTotal = 0;
  int rated = 0;

  double get average => rated == 0 ? 0 : ratingTotal / rated;
  int get score => views + feedback * 3;
}

class _Comment {
  _Comment(this.place, this.text, this.rating, this.time);

  final String place;
  final String text;
  final int rating;
  final int time;
}

class _AnalyticsData {
  int users = 0;
  int newUsersWeek = 0;
  int tourists = 0;
  int owners = 0;
  int admins = 0;
  int ownersWaiting = 0;
  int destinations = 0;
  int events = 0;
  final businessByStatus = <String, int>{};
  int feedbackCount = 0;
  double averageRating = 0;
  final ratingCounts = List<int>.filled(5, 0); // index 0 = 1 star
  List<_PlaceRating> topPlaces = [];
  List<_Viewed> topDestinations = [];
  List<_Viewed> topBusinesses = [];
  List<_EventStat> eventStats = [];
  List<MapEntry<String, int>> topTags = [];
  List<_Comment> recent = [];
  List<ChartPoint> viewsPerDay = [];
  List<ChartPoint> signupsPerDay = [];
  int totalViews = 0;
  int viewsWeek = 0;
  final denied = <String>[];

  int get businesses =>
      businessByStatus.values.fold(0, (sum, value) => sum + value);
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Future<_AnalyticsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _reload() {
    setState(() => _future = _load());
  }

  int _asInt(dynamic raw) =>
      raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;

  /// Reads one node. If the database rules refuse it, the page keeps
  /// working and just shows a note for that part.
  Future<Map<dynamic, dynamic>> _readNode(
    String path,
    _AnalyticsData data,
  ) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref(path).get();
      final value = snapshot.value;
      return value is Map ? value : <dynamic, dynamic>{};
    } catch (_) {
      data.denied.add(path);
      return <dynamic, dynamic>{};
    }
  }

  Future<_AnalyticsData> _load() async {
    final data = _AnalyticsData();

    final results = await Future.wait([
      _readNode('users', data),
      _readNode('destinations', data),
      _readNode('events', data),
      _readNode('businesses', data),
      _readNode('feedback', data),
      _readNode('analytics/views', data),
      _readNode('analytics/daily', data),
    ]);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    // ---- Users + sign-ups per day (last 14 days) ----
    final signups = <String, int>{};
    for (final entry in results[0].values) {
      if (entry is! Map) continue;
      data.users++;
      final role = entry['role']?.toString() ?? 'tourist';
      if (role == 'admin') {
        data.admins++;
      } else if (role == 'business_owner') {
        data.owners++;
        if (entry['approved'] != true) data.ownersWaiting++;
      } else {
        data.tourists++;
      }
      final created = _asInt(entry['createdAt']);
      if (created >= weekAgo) data.newUsersWeek++;
      if (created > 0) {
        final key = dayKey(DateTime.fromMillisecondsSinceEpoch(created));
        signups[key] = (signups[key] ?? 0) + 1;
      }
    }

    // ---- Page views per day (last 14 days) ----
    final dailyViews = <String, int>{};
    results[6].forEach((k, v) => dailyViews[k.toString()] = _asInt(v));
    for (var i = 13; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final key = dayKey(day);
      final label = '${day.day}/${day.month}';
      data.viewsPerDay.add(ChartPoint(label, dailyViews[key] ?? 0));
      data.signupsPerDay.add(ChartPoint(label, signups[key] ?? 0));
      if (i < 7) data.viewsWeek += dailyViews[key] ?? 0;
    }

    // ---- Destinations / events / businesses ----
    data.destinations = results[1].values.whereType<Map>().length;
    data.events = results[2].values.whereType<Map>().length;

    for (final entry in results[3].values) {
      if (entry is! Map) continue;
      final status = entry['status']?.toString() ?? 'pending';
      data.businessByStatus[status] = (data.businessByStatus[status] ?? 0) + 1;
    }

    // ---- Views per item ----
    final destViews = <_Viewed>[];
    final bizViews = <_Viewed>[];
    final eventViews = <String, int>{}; // event id -> views
    for (final entry in results[5].values) {
      if (entry is! Map) continue;
      final type = entry['type']?.toString() ?? '';
      final count = _asInt(entry['count']);
      final name = entry['name']?.toString() ?? 'Unknown';
      data.totalViews += count;
      if (type == 'destination') {
        destViews.add(_Viewed(name, count));
      } else if (type == 'business') {
        bizViews.add(_Viewed(name, count));
      } else if (type == 'event') {
        eventViews[entry['id']?.toString() ?? ''] = count;
      }
    }
    destViews.sort((a, b) => b.count.compareTo(a.count));
    bizViews.sort((a, b) => b.count.compareTo(a.count));
    data.topDestinations = destViews.take(6).toList();
    data.topBusinesses = bizViews.take(5).toList();

    // ---- Feedback ----
    final perPlace = <String, _PlaceRating>{};
    final tags = <String, int>{};
    final comments = <_Comment>[];
    var ratingSum = 0;
    final feedbackEntries = results[4].values.whereType<Map>().toList();

    for (final entry in feedbackEntries) {
      final rating = _asInt(entry['rating']).clamp(0, 5).toInt();
      final place = entry['place']?.toString() ?? 'Unknown place';
      data.feedbackCount++;
      if (rating >= 1) {
        data.ratingCounts[rating - 1]++;
        ratingSum += rating;
        final pr = perPlace.putIfAbsent(place, () => _PlaceRating(place));
        pr.total += rating;
        pr.count++;
      }
      final rawTags = entry['tags'];
      if (rawTags is List) {
        for (final t in rawTags) {
          final tag = t?.toString() ?? '';
          if (tag.isNotEmpty) tags[tag] = (tags[tag] ?? 0) + 1;
        }
      } else if (rawTags is Map) {
        for (final t in rawTags.values) {
          final tag = t?.toString() ?? '';
          if (tag.isNotEmpty) tags[tag] = (tags[tag] ?? 0) + 1;
        }
      }
      final text = entry['comment']?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        comments.add(_Comment(place, text, rating, _asInt(entry['timestamp'])));
      }
    }
    final rated = data.ratingCounts.fold(0, (a, b) => a + b);
    data.averageRating = rated == 0 ? 0 : ratingSum / rated;

    final top = perPlace.values.toList()
      ..sort((a, b) {
        final byAvg = b.average.compareTo(a.average);
        return byAvg != 0 ? byAvg : b.count.compareTo(a.count);
      });
    data.topPlaces = top.take(5).toList();

    final tagList = tags.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    data.topTags = tagList.take(6).toList();

    comments.sort((a, b) => b.time.compareTo(a.time));
    data.recent = comments.take(5).toList();

    // ---- Event engagement (views + feedback matched by event name) ----
    final stats = <_EventStat>[];
    results[2].forEach((id, raw) {
      if (raw is! Map) return;
      final nameEn = raw['name_en']?.toString() ?? '';
      final nameAr = raw['name_ar']?.toString() ?? '';
      final stat = _EventStat(nameEn.isEmpty ? nameAr : nameEn);
      stat.views = eventViews[id.toString()] ?? 0;
      for (final fb in feedbackEntries) {
        final place = fb['place']?.toString() ?? '';
        if (place.isEmpty) continue;
        if (place == nameEn || place == nameAr) {
          stat.feedback++;
          final r = _asInt(fb['rating']).clamp(0, 5).toInt();
          if (r >= 1) {
            stat.ratingTotal += r;
            stat.rated++;
          }
        }
      }
      stats.add(stat);
    });
    stats.sort((a, b) => b.score.compareTo(a.score));
    data.eventStats = stats.take(6).toList();

    return data;
  }

  String _tagLabel(String key) {
    switch (key) {
      case 'Easy to use':
        return tr('tag_easy_to_use');
      case 'Helpful information':
        return tr('tag_helpful_info');
      case 'Needs Improvement':
        return tr('tag_needs_improvement');
      default:
        return key;
    }
  }

  String _reportText(_AnalyticsData d) {
    String f(String key, Map<String, Object> vars) {
      var out = tr(key);
      vars.forEach((k, v) => out = out.replaceAll('{$k}', '$v'));
      return out;
    }

    final b = StringBuffer()
      ..writeln(tr('d_an_rep_title'))
      ..writeln(f('d_an_rep_generated', {'date': dayKey(DateTime.now())}))
      ..writeln()
      ..writeln(f('d_an_rep_users', {'n': d.users, 'w': d.newUsersWeek}))
      ..writeln(
        f('d_an_rep_roles', {'t': d.tourists, 'o': d.owners, 'a': d.admins}),
      )
      ..writeln(f('d_an_rep_destinations', {'n': d.destinations}))
      ..writeln(f('d_an_rep_events', {'n': d.events}))
      ..writeln(f('d_an_rep_businesses', {'n': d.businesses}))
      ..writeln(f('d_an_rep_views', {'n': d.totalViews, 'w': d.viewsWeek}))
      ..writeln(
        f('d_an_rep_feedback', {
          'n': d.feedbackCount,
          'avg': d.averageRating == 0 ? '-' : d.averageRating.toStringAsFixed(1),
        }),
      );
    if (d.topDestinations.isNotEmpty) {
      b
        ..writeln()
        ..writeln(tr('d_an_rep_most_viewed'));
      for (var i = 0; i < d.topDestinations.length; i++) {
        b.writeln(f('d_an_rep_item_views', {
          'i': i + 1,
          'name': d.topDestinations[i].name,
          'n': d.topDestinations[i].count,
        }));
      }
    }
    if (d.eventStats.isNotEmpty) {
      b
        ..writeln()
        ..writeln(tr('d_an_rep_event_engagement'));
      for (final e in d.eventStats) {
        b.writeln(f('d_an_rep_event_line', {
              'name': e.name,
              'v': e.views,
              'f': e.feedback,
            }) +
            (e.rated == 0 ? '' : ', ${e.average.toStringAsFixed(1)}/5'));
      }
    }
    if (d.topPlaces.isNotEmpty) {
      b
        ..writeln()
        ..writeln(tr('d_an_rep_top_rated'));
      for (final p in d.topPlaces) {
        b.writeln('- ${p.place}: ${p.average.toStringAsFixed(1)}/5 (${p.count})');
      }
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('d_an_title')),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: tr('d_an_refresh'),
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<_AnalyticsData>(
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
                  '${tr('d_an_load_error')}\n${snapshot.error ?? ''}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(_AnalyticsData d) {
    final maxDest = d.topDestinations.isEmpty ? 0 : d.topDestinations.first.count;
    final maxBiz = d.topBusinesses.isEmpty ? 0 : d.topBusinesses.first.count;
    final maxEvent = d.eventStats.fold<int>(0, (m, e) => e.views > m ? e.views : m);
    final maxRating = d.ratingCounts.reduce((a, b) => a > b ? a : b);
    final maxTag = d.topTags.isEmpty ? 0 : d.topTags.first.value;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            if (d.denied.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tr('d_an_denied').replaceAll('{paths}', d.denied.join(', ')),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                StatTile(
                  icon: Icons.people_alt,
                  label: tr('d_an_users'),
                  value: '${d.users}',
                  note: tr('d_an_new_week').replaceAll('{n}', '${d.newUsersWeek}'),
                  color: Colors.brown[800]!,
                ),
                StatTile(
                  icon: Icons.visibility,
                  label: tr('d_an_page_views'),
                  value: '${d.totalViews}',
                  note: tr('d_an_last7').replaceAll('{n}', '${d.viewsWeek}'),
                  color: Colors.brown[600]!,
                ),
                StatTile(
                  icon: Icons.map,
                  label: tr('d_an_destinations'),
                  value: '${d.destinations}',
                  note: tr('d_an_events_n').replaceAll('{n}', '${d.events}'),
                  color: Colors.brown[500]!,
                ),
                StatTile(
                  icon: Icons.storefront,
                  label: tr('d_an_businesses'),
                  value: '${d.businesses}',
                  color: Colors.brown[400]!,
                ),
                StatTile(
                  icon: Icons.reviews,
                  label: tr('d_an_feedback'),
                  value: '${d.feedbackCount}',
                  color: Colors.brown[700]!,
                ),
                StatTile(
                  icon: Icons.star,
                  label: tr('d_an_avg_rating'),
                  value: d.averageRating == 0
                      ? '-'
                      : d.averageRating.toStringAsFixed(1),
                  note: tr('d_an_out_of_5'),
                  color: Colors.amber[800]!,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ChartCard(
              title: tr('d_an_app_activity'),
              subtitle: tr('d_an_views_per_day'),
              child: VerticalBarChart(
                points: d.viewsPerDay,
                color: Colors.brown[600]!,
              ),
            ),
            ChartCard(
              title: tr('d_an_new_signups'),
              subtitle: tr('d_an_signups_per_day'),
              child: LineChart(
                points: d.signupsPerDay,
                color: Colors.brown[800]!,
              ),
            ),
            ChartCard(
              title: tr('d_an_users_by_role'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DonutChart(
                    centerLabel: tr('d_an_users_lower'),
                    slices: [
                      ChartSlice(tr('d_an_tourists'), d.tourists, Colors.brown[300]!),
                      ChartSlice(tr('d_an_owners'), d.owners, Colors.brown[600]!),
                      ChartSlice(tr('d_an_admins'), d.admins, Colors.brown[900]!),
                    ],
                  ),
                  if (d.ownersWaiting > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        tr('d_an_owners_waiting').replaceAll('{n}', '${d.ownersWaiting}'),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ChartCard(
              title: tr('d_an_biz_by_status'),
              child: d.businesses == 0
                  ? ChartEmptyNote(tr('d_an_no_businesses'))
                  : DonutChart(
                      centerLabel: tr('d_an_listings'),
                      slices: [
                        for (final status in const [
                          'approved',
                          'pending',
                          'delete_requested',
                          'rejected',
                        ])
                          ChartSlice(
                            businessStatusLabel(status),
                            d.businessByStatus[status] ?? 0,
                            businessStatusColor(status),
                          ),
                      ],
                    ),
            ),
            ChartCard(
              title: tr('d_an_most_viewed_places'),
              subtitle: tr('d_an_dest_opened'),
              child: d.topDestinations.isEmpty
                  ? ChartEmptyNote(tr('d_an_no_views'))
                  : Column(
                      children: [
                        for (final v in d.topDestinations)
                          BarRow(
                            label: v.name,
                            value: v.count,
                            max: maxDest,
                            color: Colors.brown[600]!,
                            labelWidth: 130,
                          ),
                      ],
                    ),
            ),
            if (d.topBusinesses.isNotEmpty)
              ChartCard(
                title: tr('d_an_most_viewed_biz'),
                child: Column(
                  children: [
                    for (final v in d.topBusinesses)
                      BarRow(
                        label: v.name,
                        value: v.count,
                        max: maxBiz,
                        color: Colors.brown[400]!,
                        labelWidth: 130,
                      ),
                  ],
                ),
              ),
            ChartCard(
              title: tr('d_an_event_engagement'),
              subtitle: tr('d_an_event_engagement_sub'),
              child: d.eventStats.isEmpty
                  ? ChartEmptyNote(tr('d_an_no_events'))
                  : Column(
                      children: [
                        for (final e in d.eventStats) ...[
                          BarRow(
                            label: e.name,
                            value: e.views,
                            max: maxEvent,
                            color: Colors.brown[500]!,
                            labelWidth: 130,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2, bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${tr('d_an_feedback_n').replaceAll('{n}', '${e.feedback}')}'
                                '${e.rated == 0 ? '' : '  -  ${e.average.toStringAsFixed(1)} / 5'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            ChartCard(
              title: tr('d_an_feedback_summary'),
              subtitle: tr('d_an_rating_breakdown'),
              child: d.feedbackCount == 0
                  ? ChartEmptyNote(tr('d_an_no_feedback'))
                  : Column(
                      children: [
                        for (var stars = 5; stars >= 1; stars--)
                          BarRow(
                            label: tr(stars == 1 ? 'd_an_star' : 'd_an_stars')
                                .replaceAll('{n}', '$stars'),
                            value: d.ratingCounts[stars - 1],
                            max: maxRating,
                            color: Colors.amber[700]!,
                          ),
                      ],
                    ),
            ),
            ChartCard(
              title: tr('d_an_top_rated'),
              child: d.topPlaces.isEmpty
                  ? ChartEmptyNote(tr('d_an_no_ratings'))
                  : Column(
                      children: [
                        for (var i = 0; i < d.topPlaces.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.brown[100],
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown[800],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    d.topPlaces[i].place,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.star,
                                    size: 16, color: Colors.amber[700]),
                                const SizedBox(width: 3),
                                Text(
                                  d.topPlaces[i].average.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' (${d.topPlaces[i].count})',
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            if (d.topTags.isNotEmpty)
              ChartCard(
                title: tr('d_an_mention_most'),
                subtitle: tr('d_an_feedback_tags'),
                child: Column(
                  children: [
                    for (final t in d.topTags)
                      BarRow(
                        label: _tagLabel(t.key),
                        value: t.value,
                        max: maxTag,
                        color: Colors.brown[300]!,
                        labelWidth: 130,
                      ),
                  ],
                ),
              ),
            if (d.recent.isNotEmpty)
              ChartCard(
                title: tr('d_an_latest_comments'),
                child: Column(
                  children: [
                    for (final c in d.recent)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote,
                                size: 18, color: Colors.brown[300]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    '${c.place}'
                                    '${c.rating > 0 ? '  -  ${c.rating}/5' : ''}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
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
                label: Text(tr('d_an_share_report')),
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