import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';

import 'explore.dart';
import 'place_icons.dart';

/// Admin screen: list every destination, add a new one, or edit/
/// delete an existing one. Backed by the same 'destinations' Firebase
/// node the tourist-facing Explore page reads from — changes here
/// show up there immediately.
class ManageDestinationsPage extends StatelessWidget {
  const ManageDestinationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('b_manage_dest')),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[800],
        icon: const Icon(Icons.add),
        label: Text(tr('b_add_dest')),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DestinationFormPage()),
          );
        },
      ),
      body: StreamBuilder(
        stream: destinationsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final value = snapshot.data?.snapshot.value;
          final destinations = <Destination>[];

          if (value is Map) {
            for (final entry in value.entries) {
              if (entry.value is Map) {
                destinations.add(
                  Destination.fromMap(entry.key.toString(), entry.value as Map),
                );
              }
            }
          }

          destinations.sort((a, b) => a.nameEn.compareTo(b.nameEn));

          if (destinations.isEmpty) {
            return Center(child: Text(tr('b_no_dest')));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final d = destinations[index];
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
                    child: Icon(d.icon, color: Colors.brown[800]),
                  ),
                  title: Text(
                    d.nameEn,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(d.locationEn),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.brown),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DestinationFormPage(existing: d),
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
                              title: Text(tr('b_delete_dest_q')),
                              content: Text(
                                tr('b_remove_confirm')
                                    .replaceAll('{name}', d.nameEn),
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
                            await destinationsRef.child(d.id).remove();
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

/// Add/edit form for a single destination. Pass [existing] to edit;
/// leave it null to create a new one.
class DestinationFormPage extends StatefulWidget {
  const DestinationFormPage({super.key, this.existing});

  final Destination? existing;

  @override
  State<DestinationFormPage> createState() => _DestinationFormPageState();
}

class _DestinationFormPageState extends State<DestinationFormPage> {
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
  late final _detailsEn =
      TextEditingController(text: widget.existing?.detailsEn);
  late final _detailsAr =
      TextEditingController(text: widget.existing?.detailsAr);
  late final _imageUrl =
      TextEditingController(text: widget.existing?.imageUrl);

  late String _iconKey = widget.existing?.iconKey ?? kDefaultPlaceIconKey;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _locationEn.dispose();
    _locationAr.dispose();
    _descriptionEn.dispose();
    _descriptionAr.dispose();
    _detailsEn.dispose();
    _detailsAr.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return tr('b_required');
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = Destination(
      id: widget.existing?.id ?? '',
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      locationEn: _locationEn.text.trim(),
      locationAr: _locationAr.text.trim(),
      descriptionEn: _descriptionEn.text.trim(),
      descriptionAr: _descriptionAr.text.trim(),
      detailsEn: _detailsEn.text.trim(),
      detailsAr: _detailsAr.text.trim(),
      iconKey: _iconKey,
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
    ).toMap();

    try {
      if (widget.existing != null) {
        await destinationsRef.child(widget.existing!.id).update(data);
      } else {
        await destinationsRef.push().set(data);
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
        title: Text(isEditing ? tr('b_edit_dest') : tr('b_add_dest')),
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
                _SectionLabel(tr('b_full_details')),
                TextFormField(
                  controller: _detailsEn,
                  decoration: _decoration(tr('b_details_en')),
                  maxLines: 5,
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _detailsAr,
                  decoration: _decoration(tr('b_details_ar')),
                  textDirection: TextDirection.rtl,
                  maxLines: 5,
                  validator: _required,
                ),

                const SizedBox(height: 18),
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
                        : Text(isEditing ? tr('b_save_changes') : tr('b_add_dest')),
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