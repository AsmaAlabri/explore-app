import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'user_roles.dart';
import 'l10n/app_strings.dart';

final usersRef = FirebaseDatabase.instance.ref('users');

/// Admin screen: every registered account, with its role and —
/// for Local Business Owner accounts — whether the admin has
/// approved them yet. A business owner can't add/manage a business
/// (see my_business.dart) until their account is approved here.
class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  Future<void> _setApproved(String uid, bool approved) {
    return usersRef.child(uid).update({'approved': approved});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: Text(tr('a_manage_users')),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: usersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final value = snapshot.data?.snapshot.value;
          final users = <_UserRow>[];

          if (value is Map) {
            for (final entry in value.entries) {
              if (entry.value is Map) {
                final data = entry.value as Map;
                users.add(
                  _UserRow(
                    uid: entry.key.toString(),
                    name: (data['name'] ?? '').toString(),
                    email: (data['email'] ?? '').toString(),
                    role: (data['role'] ?? defaultUserRole).toString(),
                    approved: data['approved'] == true,
                  ),
                );
              }
            }
          }

          if (users.isEmpty) {
            return Center(child: Text(tr('a_no_users')));
          }

          // Business owners waiting on approval first, then everyone
          // else alphabetically by name.
          users.sort((a, b) {
            final aPending = a.role == 'business_owner' && !a.approved;
            final bPending = b.role == 'business_owner' && !b.approved;
            if (aPending != bPending) return aPending ? -1 : 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserCard(
                user: user,
                onApprove: () => _setApproved(user.uid, true),
                onRevoke: () => _setApproved(user.uid, false),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserRow {
  const _UserRow({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.approved,
  });

  final String uid;
  final String name;
  final String email;
  final String role;
  final bool approved;
}

Color _roleColor(String role) {
  switch (role) {
    case 'admin':
      return Colors.brown[900]!;
    case 'business_owner':
      return Colors.brown[500]!;
    default:
      return Colors.brown[300]!;
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onApprove,
    required this.onRevoke,
  });

  final _UserRow user;
  final VoidCallback onApprove;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final isBusinessOwner = user.role == 'business_owner';
    final initial =
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

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
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.brown[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? tr('a_no_name') : user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _roleColor(user.role).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  roleLabelTr(user.role),
                  style: TextStyle(
                    color: _roleColor(user.role),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (isBusinessOwner) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (user.approved ? Colors.green : Colors.orange)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.approved ? tr('a_approved') : tr('a_waiting_approval'),
                    style: TextStyle(
                      color: user.approved ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                if (user.approved)
                  OutlinedButton.icon(
                    onPressed: onRevoke,
                    icon: const Icon(Icons.block, size: 16, color: Colors.red),
                    label: Text(
                      tr('a_revoke'),
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(tr('a_approve')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}