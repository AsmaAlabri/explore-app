import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'l10n/app_strings.dart';

/// Admin screen: every feedback entry submitted anywhere in the app
/// (any destination or event), newest first, with the submitter's
/// name resolved from their account when possible.
class AllFeedbackPage extends StatefulWidget {
  const AllFeedbackPage({super.key});

  @override
  State<AllFeedbackPage> createState() => _AllFeedbackPageState();
}

class _AllFeedbackPageState extends State<AllFeedbackPage> {
  final _feedbackRef = FirebaseDatabase.instance.ref('feedback');
  Map<String, String> _userNames = {};
  bool _usersLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('users').get();
      final value = snapshot.value;
      final names = <String, String>{};

      if (value is Map) {
        for (final entry in value.entries) {
          final data = entry.value;
          if (data is Map) {
            final name = data['name']?.toString();
            if (name != null && name.isNotEmpty) {
              names[entry.key.toString()] = name;
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _userNames = names;
        _usersLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _usersLoaded = true);
    }
  }

  String _formatTimestamp(dynamic raw) {
    final millis = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    if (millis == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('a_all_feedback')),
        centerTitle: true,
      ),
      body: !_usersLoaded
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DatabaseEvent>(
              stream: _feedbackRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(tr('a_error_prefix').replaceAll('{error}', '${snapshot.error}')));
                }

                final value = snapshot.data?.snapshot.value;

                if (value is! Map || value.isEmpty) {
                  return Center(
                    child: Text(tr('a_no_feedback')),
                  );
                }

                final entries = value.entries.toList()
                  ..sort((a, b) {
                    final tsA = (a.value as Map)['timestamp'];
                    final tsB = (b.value as Map)['timestamp'];
                    final numA = tsA is int ? tsA : 0;
                    final numB = tsB is int ? tsB : 0;
                    return numB.compareTo(numA); // newest first
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final data = Map<String, dynamic>.from(
                      entries[index].value as Map,
                    );

                    final place = data['place']?.toString() ?? tr('a_unknown_place');
                    final comment = data['comment']?.toString() ?? '';
                    final rating = (data['rating'] is int)
                        ? data['rating'] as int
                        : int.tryParse(data['rating']?.toString() ?? '') ?? 0;
                    final userId = data['userId']?.toString();
                    final submittedBy = userId != null
                        ? (_userNames[userId] ?? tr('a_unknown_user'))
                        : tr('a_unknown_user');
                    final tags = (data['tags'] is List)
                        ? List<String>.from(
                            (data['tags'] as List).map((e) => e.toString()),
                          )
                        : <String>[];
                    final when = _formatTimestamp(data['timestamp']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  place,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < rating ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber[700],
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr('a_feedback_by').replaceAll('{name}', submittedBy) +
                                (when.isNotEmpty ? " · $when" : ""),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                          if (comment.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(comment, style: const TextStyle(fontSize: 13)),
                          ],
                          if (tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: tags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(
                                        tag,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: Colors.brown[50],
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}