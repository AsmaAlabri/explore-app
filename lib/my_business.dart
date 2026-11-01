import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'business.dart';
import 'business_report.dart';
import 'l10n/app_strings.dart';
import 'place_icons.dart';

/// Business Owner's own page: add, edit, or delete any number of
/// business listings. Every change (new listing, edit, or delete)
/// goes to the admin as a pending request first — see business.dart
/// for the full status workflow. Only reachable by an account whose
/// role is 'business_owner'; also checks the admin's account-level
/// approval (the same 'approved' flag set in Manage Users) before
/// letting them do anything.
class MyBusinessPage extends StatelessWidget {
  const MyBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F1EE),
        appBar: AppBar(
          backgroundColor: Colors.brown[900],
          title: Text(tr('c_my_business')),
          centerTitle: true,
        ),
        body: Center(child: Text(tr('c_login_required'))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('c_my_business')),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: tr('c_business_report_tip'),
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusinessReportPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('users/$uid').onValue,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userValue = userSnapshot.data?.snapshot.value;
          final userData = userValue is Map
              ? Map<String, dynamic>.from(userValue)
              : <String, dynamic>{};

          final role = userData['role']?.toString() ?? 'tourist';
          final approved = userData['approved'] == true;
          final name = userData['name']?.toString() ?? '';

          if (role != 'business_owner') {
            return _InfoMessage(
              icon: Icons.storefront_outlined,
              title: tr('c_owner_only_title'),
              message: tr('c_owner_only_msg'),
            );
          }

          if (!approved) {
            return _InfoMessage(
              icon: Icons.hourglass_top,
              title: tr('c_wait_approval_title'),
              message: tr('c_wait_approval_msg'),
            );
          }

          return StreamBuilder<DatabaseEvent>(
            stream: businessesRef.onValue,
            builder: (context, bizSnapshot) {
              if (bizSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final value = bizSnapshot.data?.snapshot.value;
              final mine = <Business>[];

              if (value is Map) {
                for (final entry in value.entries) {
                  if (entry.value is Map) {
                    final b = Business.fromMap(
                      entry.key.toString(),
                      entry.value as Map,
                    );
                    if (b.ownerId == uid) {
                      mine.add(b);
                    }
                  }
                }
              }

              mine.sort((a, b) => a.name.compareTo(b.name));

              if (mine.isEmpty) {
                return _EmptyBusinessState(ownerId: uid, ownerName: name);
              }

              return _MyBusinessList(
                businesses: mine,
                ownerId: uid,
                ownerName: name,
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.brown[400]),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBusinessState extends StatelessWidget {
  const _EmptyBusinessState({required this.ownerId, required this.ownerName});

  final String ownerId;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, size: 56, color: Colors.brown[400]),
            const SizedBox(height: 16),
            Text(
              tr('c_no_business_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              tr('c_no_business_msg'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(tr('c_add_your_business')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BusinessFormPage(
                      ownerId: ownerId,
                      ownerName: ownerName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows every business this owner has, each as its own card, with an
/// "Add Another Business" button so they're not limited to just one.
class _MyBusinessList extends StatelessWidget {
  const _MyBusinessList({
    required this.businesses,
    required this.ownerId,
    required this.ownerName,
  });

  final List<Business> businesses;
  final String ownerId;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        for (final business in businesses) ...[
          _MyBusinessCard(business: business),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.brown[800],
              side: BorderSide(color: Colors.brown[800]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(tr('c_add_another_business')),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BusinessFormPage(
                    ownerId: ownerId,
                    ownerName: ownerName,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MyBusinessCard extends StatelessWidget {
  const _MyBusinessCard({required this.business});

  final Business business;

  Future<void> _requestDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('c_remove_business_q')),
        content: (business.status == 'pending' ||
                business.status == 'rejected')
            ? Text(tr('c_remove_pending_msg'))
            : Text(tr('c_remove_live_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr('c_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr('c_remove'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (business.status == 'pending' || business.status == 'rejected') {
      // Nothing live yet — just delete outright.
      await businessesRef.child(business.id).remove();
    } else {
      // Live (approved) — ask the admin to confirm removal.
      await businessesRef.child(business.id).update({
        'status': 'delete_requested',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: no SingleChildScrollView here — this card is placed inside
    // a parent ListView (see _MyBusinessList) alongside the owner's
    // other businesses, so it just returns its content directly.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: businessStatusColor(business.status).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: businessStatusColor(business.status).withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: businessStatusColor(business.status),
              ),
              const SizedBox(width: 8),
              Text(
                businessStatusLabel(business.status),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: businessStatusColor(business.status),
                  ),
                ),
              ],
            ),
          ),
          if (business.status == 'rejected')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                tr('c_rejected_note'),
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
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
                    CircleAvatar(
                      backgroundColor: Colors.brown[100],
                      child: Icon(business.icon, color: Colors.brown[800]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        business.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(business.location,
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Text(business.description),
                if (business.phone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.brown),
                      const SizedBox(width: 6),
                      Text(business.phone),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.edit),
                  label: Text(tr('c_edit')),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessFormPage(
                          ownerId: business.ownerId,
                          ownerName: business.ownerName,
                          existing: business,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(tr('c_delete')),
                  onPressed: business.status == 'delete_requested'
                      ? null
                      : () => _requestDelete(context),
                ),
              ),
            ],
          ),
        ],
      );
  }
}

/// Add/edit form for the owner's own business. Saving always sends it
/// back to 'pending' (unless [isAdminEdit] is true — used by the admin
/// Manage Businesses screen instead, where saving takes effect right
/// away without needing a second approval).
class BusinessFormPage extends StatefulWidget {
  const BusinessFormPage({
    super.key,
    required this.ownerId,
    required this.ownerName,
    this.existing,
    this.isAdminEdit = false,
  });

  final String ownerId;
  final String ownerName;
  final Business? existing;
  final bool isAdminEdit;

  @override
  State<BusinessFormPage> createState() => _BusinessFormPageState();
}

class _BusinessFormPageState extends State<BusinessFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final _name = TextEditingController(text: widget.existing?.name);
  late final _location =
      TextEditingController(text: widget.existing?.location);
  late final _description =
      TextEditingController(text: widget.existing?.description);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _imageUrl =
      TextEditingController(text: widget.existing?.imageUrl);

  late String _iconKey = widget.existing?.iconKey ?? kDefaultPlaceIconKey;
  bool _isSaving = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    _phone.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return tr('c_required');
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final status = widget.isAdminEdit
        ? (widget.existing?.status ?? 'approved')
        : 'pending';

    final data = Business(
      id: widget.existing?.id ?? '',
      ownerId: widget.ownerId,
      ownerName: widget.ownerName,
      name: _name.text.trim(),
      location: _location.text.trim(),
      description: _description.text.trim(),
      phone: _phone.text.trim(),
      iconKey: _iconKey,
      status: status,
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
    ).toMap();

    try {
      if (widget.existing != null) {
        await businessesRef.child(widget.existing!.id).update(data);
      } else {
        await businessesRef.push().set(data);
      }
      if (!mounted) return;
      Navigator.pop(context);
      if (!widget.isAdminEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('c_sent_for_approval'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('c_could_not_save').replaceAll('{error}', '$e'))),
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
        title: Text(isEditing ? tr('c_edit_business') : tr('c_add_your_business')),
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
                if (!widget.isAdminEdit)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tr('c_form_notice'),
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                TextFormField(
                  controller: _name,
                  decoration: _decoration(tr('c_business_name')),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _location,
                  decoration: _decoration(tr('c_location')),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _description,
                  decoration: _decoration(tr('c_description')),
                  maxLines: 3,
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phone,
                  decoration: _decoration(tr('c_contact_phone')),
                  keyboardType: TextInputType.phone,
                  validator: _required,
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: _iconKey,
                  decoration: _decoration(tr('c_icon')),
                  items: placeIcons.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Row(
                            children: [
                              Icon(entry.value,
                                  size: 20, color: Colors.brown[800]),
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
                TextFormField(
                  controller: _imageUrl,
                  decoration:
                      _decoration(tr('c_photo_url')),
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
                        : Text(isEditing ? tr('c_save_changes') : tr('c_submit')),
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