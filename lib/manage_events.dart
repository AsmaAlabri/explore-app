import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';

import 'events.dart';
import 'place_icons.dart';

/// Admin screen: list every event, add a new one, or edit/delete an
/// existing one. Backed by the same 'events' Firebase node the
/// tourist-facing Events page reads from — changes here show up
/// there immediately.
class ManageEventsPage extends StatelessWidget {
  const ManageEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('b_manage_events')),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[800],
        icon: const Icon(Icons.add),
        label: Text(tr('b_add_event')),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormPage()),
          );
        },
      ),
      body: StreamBuilder(
        stream: eventsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final value = snapshot.data?.snapshot.value;
          final events = <EventItem>[];

          if (value is Map) {
            for (final entry in value.entries) {
              if (entry.value is Map) {
                events.add(
                  EventItem.fromMap(entry.key.toString(), entry.value as Map),
                );
              }
            }
          }

          events.sort((a, b) => a.nameEn.compareTo(b.nameEn));

          if (events.isEmpty) {
            return Center(child: Text(tr('b_no_events')));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown[100],
                    child: Icon(e.icon, color: Colors.brown[800]),
                  ),
                  title: Text(
                    e.nameEn,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(e.locationEn),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.brown),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventFormPage(existing: e),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(tr('b_delete_event_q')),
                              content: Text(
                                tr('b_remove_confirm')
                                    .replaceAll('{name}', e.nameEn),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: Text(tr('b_cancel')),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: Text(
                                    tr('b_delete'),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await eventsRef.child(e.id).remove();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoLinePair {
  _InfoLinePair({String en = '', String ar = ''})
      : en = TextEditingController(text: en),
        ar = TextEditingController(text: ar);

  final TextEditingController en;
  final TextEditingController ar;

  void dispose() {
    en.dispose();
    ar.dispose();
  }
}

/// Add/edit form for a single event. Pass [existing] to edit; leave
/// it null to create a new one.
class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key, this.existing});

  final EventItem? existing;

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final _nameEn = TextEditingController(text: widget.existing?.nameEn);
  late final _nameAr = TextEditingController(text: widget.existing?.nameAr);
  late final _locationEn =
      TextEditingController(text: widget.existing?.locationEn);
  late final _locationAr =
      TextEditingController(text: widget.existing?.locationAr);
  late final _descriptionEn =
      TextEditingController(text: widget.existing?.descriptionEn);
  late final _descriptionAr =
      TextEditingController(text: widget.existing?.descriptionAr);
  late final _imageUrl =
      TextEditingController(text: widget.existing?.imageUrl);

  late String _iconKey = widget.existing?.iconKey ?? 'celebration';
  late final List<_InfoLinePair> _lines = _initialLines();
  bool _isSaving = false;

  List<_InfoLinePair> _initialLines() {
    final en = widget.existing?.infoLinesEn ?? const [];
    final ar = widget.existing?.infoLinesAr ?? const [];

    if (en.isEmpty) {
      return [_InfoLinePair(), _InfoLinePair(), _InfoLinePair()];
    }

    return List.generate(en.length, (i) {
      return _InfoLinePair(en: en[i], ar: i < ar.length ? ar[i] : '');
    });
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _locationEn.dispose();
    _locationAr.dispose();
    _descriptionEn.dispose();
    _descriptionAr.dispose();
    _imageUrl.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return tr('b_required');
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final linesEn = _lines
        .map((l) => l.en.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final linesAr = _lines
        .map((l) => l.ar.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final data = EventItem(
      id: widget.existing?.id ?? '',
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      locationEn: _locationEn.text.trim(),
      locationAr: _locationAr.text.trim(),
      descriptionEn: _descriptionEn.text.trim(),
      descriptionAr: _descriptionAr.text.trim(),
      infoLinesEn: linesEn,
      infoLinesAr: linesAr.isNotEmpty ? linesAr : linesEn,
      iconKey: _iconKey,
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
    ).toMap();

    try {
      if (widget.existing != null) {
        await eventsRef.child(widget.existing!.id).update(data);
      } else {
        await eventsRef.push().set(data);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('b_could_not_save').replaceAll('{error}', '$e')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(isEditing ? tr('b_edit_event') : tr('b_add_event')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionLabel(tr('b_name')),
                TextFormField(
                  controller: _nameEn,
                  decoration: _decoration(tr('b_name_en')),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameAr,
                  decoration: _decoration(tr('b_name_ar')),
                  textDirection: TextDirection.rtl,
                  validator: _required,
                ),

                const SizedBox(height: 18),
                _SectionLabel(tr('b_location')),
                TextFormField(
                  controller: _locationEn,
                  decoration: _decoration(tr('b_location_en')),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _locationAr,
                  decoration: _decoration(tr('b_location_ar')),
                  textDirection: TextDirection.rtl,
                  validator: _required,
                ),

                const SizedBox(height: 18),
                _SectionLabel(tr('b_short_desc')),
                TextFormField(
                  controller: _descriptionEn,
                  decoration: _decoration(tr('b_desc_en')),
                  maxLines: 2,
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionAr,
                  decoration: _decoration(tr('b_desc_ar')),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  validator: _required,
                ),

                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _SectionLabel(tr('b_info_lines')),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _lines.add(_InfoLinePair()));
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(tr('b_add_line')),
                    ),
                  ],
                ),
                ..._lines.asMap().entries.map((entry) {
                  final i = entry.key;
                  final pair = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              tr('b_line_n').replaceAll('{n}', '${i + 1}'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (_lines.length > 1)
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _lines.removeAt(i).dispose();
                                  });
                                },
                              ),
                          ],
                        ),
                        TextFormField(
                          controller: pair.en,
                          decoration: _decoration(tr('b_english')),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: pair.ar,
                          decoration: _decoration(tr('b_arabic')),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),
                _SectionLabel(tr('b_icon')),
                DropdownButtonFormField<String>(
                  value: _iconKey,
                  decoration: _decoration(tr('b_icon')),
                  items: placeIcons.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Row(
                            children: [
                              Icon(entry.value, size: 20, color: Colors.brown[800]),
                              const SizedBox(width: 10),
                              Text(entry.key),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _iconKey = value);
                  },
                ),

                const SizedBox(height: 18),
                _SectionLabel(tr('b_photo_url')),
                TextFormField(
                  controller: _imageUrl,
                  decoration: _decoration('https://...'),
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 28),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEditing ? tr('b_save_changes') : tr('b_add_event')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.brown,
        ),
      ),
    );
  }
}