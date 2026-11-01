import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';

import 'business.dart';
import 'my_business.dart';

/// Admin screen: every business listing, grouped so pending requests
/// and delete requests need attention first. Admin can approve/reject
/// a new listing, confirm/cancel a delete request, or directly edit
/// or delete any business outright (no approval loop needed — the
/// admin is already the approving authority).
class ManageBusinessesPage extends StatelessWidget {
  const ManageBusinessesPage({super.key});

  Future<void> _approve(Business b) {
    return businessesRef.child(b.id).update({'status': 'approved'});
  }

  Future<void> _reject(Business b) {
    return businessesRef.child(b.id).update({'status': 'rejected'});
  }

  /// Undo a rejection — puts it back in the pending queue so it can be
  /// approved (or rejected again) instead of staying stuck as rejected.
  Future<void> _undoReject(Business b) {
    return businessesRef.child(b.id).update({'status': 'pending'});
  }

  Future<void> _confirmDelete(Business b) {
    return businessesRef.child(b.id).remove();
  }

  Future<void> _cancelDeleteRequest(Business b) {
    return businessesRef.child(b.id).update({'status': 'approved'});
  }

  Future<void> _adminDelete(BuildContext context, Business b) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('b_delete_biz_q')),
        content: Text(tr('b_remove_confirm').replaceAll('{name}', b.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr('b_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr('b_delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await businessesRef.child(b.id).remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('b_manage_biz')),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[800],
        icon: const Icon(Icons.add),
        label: Text(tr('b_add_biz')),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BusinessFormPage(
                ownerId: 'admin',
                ownerName: 'Admin',
                isAdminEdit: true,
              ),
            ),
          );
        },
      ),
      body: StreamBuilder(
        stream: businessesRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final value = snapshot.data?.snapshot.value;
          final businesses = <Business>[];

          if (value is Map) {
            for (final entry in value.entries) {
              if (entry.value is Map) {
                businesses.add(
                  Business.fromMap(entry.key.toString(), entry.value as Map),
                );
              }
            }
          }

          if (businesses.isEmpty) {
            return Center(child: Text(tr('b_no_biz')));
          }

          // Needs-attention first (pending, delete_requested), then
          // approved, then rejected.
          const order = {
            'pending': 0,
            'delete_requested': 1,
            'approved': 2,
            'rejected': 3,
          };
          businesses.sort((a, b) {
            final byStatus =
                (order[a.status] ?? 9).compareTo(order[b.status] ?? 9);
            if (byStatus != 0) return byStatus;
            return a.name.compareTo(b.name);
          });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final b = businesses[index];
              return _BusinessAdminCard(
                business: b,
                onApprove: () => _approve(b),
                onReject: () => _reject(b),
                onUndoReject: () => _undoReject(b),
                onConfirmDelete: () => _confirmDelete(b),
                onCancelDeleteRequest: () => _cancelDeleteRequest(b),
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessFormPage(
                        ownerId: b.ownerId,
                        ownerName: b.ownerName,
                        existing: b,
                        isAdminEdit: true,
                      ),
                    ),
                  );
                },
                onDelete: () => _adminDelete(context, b),
              );
            },
          );
        },
      ),
    );
  }
}

class _BusinessAdminCard extends StatelessWidget {
  const _BusinessAdminCard({
    required this.business,
    required this.onApprove,
    required this.onReject,
    required this.onUndoReject,
    required this.onConfirmDelete,
    required this.onCancelDeleteRequest,
    required this.onEdit,
    required this.onDelete,
  });

  final Business business;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onUndoReject;
  final VoidCallback onConfirmDelete;
  final VoidCallback onCancelDeleteRequest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      business.location,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      tr('b_owner_n').replaceAll('{name}', business.ownerName),
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: businessStatusColor(business.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  businessStatusLabel(business.status),
                  style: TextStyle(
                    color: businessStatusColor(business.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (business.status == 'pending') ...[
                _ActionChip(
                  label: tr('b_approve'),
                  color: Colors.green,
                  icon: Icons.check,
                  onTap: onApprove,
                ),
                _ActionChip(
                  label: tr('b_reject'),
                  color: Colors.red,
                  icon: Icons.close,
                  onTap: onReject,
                ),
              ],
              if (business.status == 'delete_requested') ...[
                _ActionChip(
                  label: tr('b_confirm_delete'),
                  color: Colors.red,
                  icon: Icons.delete_forever,
                  onTap: onConfirmDelete,
                ),
                _ActionChip(
                  label: tr('b_keep_listing'),
                  color: Colors.green,
                  icon: Icons.undo,
                  onTap: onCancelDeleteRequest,
                ),
              ],
              if (business.status == 'rejected')
                _ActionChip(
                  label: tr('b_undo_reject'),
                  color: Colors.green,
                  icon: Icons.undo,
                  onTap: onUndoReject,
                ),
              _ActionChip(
                label: tr('b_edit'),
                color: Colors.brown,
                icon: Icons.edit,
                onTap: onEdit,
              ),
              _ActionChip(
                label: tr('b_delete'),
                color: Colors.red,
                icon: Icons.delete_outline,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withOpacity(0.08),
      onPressed: onTap,
    );
  }
}