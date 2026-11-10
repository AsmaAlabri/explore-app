import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'announcements.dart';
import 'app_settings.dart';
import 'l10n/app_strings.dart';

/// Admin screen: post an announcement (event update or general news) and
/// delete old ones. Tourists see them on the Notifications page.
class ManageAnnouncementsPage extends StatelessWidget {
  const ManageAnnouncementsPage({super.key});

  Future<void> _delete(BuildContext context, Announcement a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('d_ann_delete_q')),
        content: Text(a.titleEn.isEmpty ? a.titleAr : a.titleEn),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr('d_ann_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              tr('d_ann_delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await announcementsRef.child(a.id).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('d_ann_title')),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(tr('d_ann_new')),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _AnnouncementFormPage()),
          );
        },
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: announcementsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = parseAnnouncements(snapshot.data?.snapshot.value);
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  tr('d_ann_empty'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final a = items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.brown[100],
                      child: Icon(
                        a.isEvent ? Icons.event : Icons.campaign,
                        color: Colors.brown[800],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.titleEn.isEmpty ? a.titleAr : a.titleEn,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.bodyEn.isEmpty ? a.bodyAr : a.bodyEn,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${a.isEvent ? tr('d_ann_event_update') : tr('d_ann_general_news')}'
                            '  -  ${timeAgo(a.createdAt, arabic: AppSettings.instance.isArabic)}',
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: tr('d_ann_delete'),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _delete(context, a),
                    ),
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

class _AnnouncementFormPage extends StatefulWidget {
  const _AnnouncementFormPage();

  @override
  State<_AnnouncementFormPage> createState() => _AnnouncementFormPageState();
}

class _AnnouncementFormPageState extends State<_AnnouncementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleEn = TextEditingController();
  final _bodyEn = TextEditingController();
  final _titleAr = TextEditingController();
  final _bodyAr = TextEditingController();
  String _kind = 'event';
  bool _saving = false;

  @override
  void dispose() {
    _titleEn.dispose();
    _bodyEn.dispose();
    _titleAr.dispose();
    _bodyAr.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await announcementsRef.push().set({
        'title_en': _titleEn.text.trim(),
        'body_en': _bodyEn.text.trim(),
        'title_ar': _titleAr.text.trim(),
        'body_ar': _bodyAr.text.trim(),
        'kind': _kind,
        'createdAt': ServerValue.timestamp,
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('d_ann_posted'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('d_ann_post_failed').replaceAll('{error}', '$e')),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('d_ann_new')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'event',
                          icon: const Icon(Icons.event),
                          label: Text(tr('d_ann_event_update')),
                        ),
                        ButtonSegment(
                          value: 'update',
                          icon: const Icon(Icons.campaign),
                          label: Text(tr('d_ann_general_news')),
                        ),
                      ],
                      selected: {_kind},
                      onSelectionChanged: (s) => setState(() => _kind = s.first),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _titleEn,
                      decoration: _decoration(tr('d_ann_title_en')),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? tr('d_ann_required') : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _bodyEn,
                      decoration: _decoration(tr('d_ann_msg_en')),
                      maxLines: 4,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? tr('d_ann_required') : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _titleAr,
                      textDirection: TextDirection.rtl,
                      decoration: _decoration(tr('d_ann_title_ar')),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _bodyAr,
                      textDirection: TextDirection.rtl,
                      decoration: _decoration(tr('d_ann_msg_ar')),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(tr('d_ann_post')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
