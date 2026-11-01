import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';
import 'place_icons.dart';

/// A local business listing posted by an approved Business Owner
/// account. Lives in its own Firebase node ('businesses'), separate
/// from 'destinations' and 'events', so Destinations/Explore is never
/// touched by any of this.
///
/// Status workflow (every change needs an admin tap before it's live):
///   'pending'          -> a new listing, or an edit to an existing
///                          one, waiting for admin approval. Not shown
///                          to tourists.
///   'approved'         -> live. Shows up as a card on the Events page
///                          alongside real events.
///   'delete_requested' -> the owner asked to remove it; still shown
///                          as approved to tourists until the admin
///                          confirms the deletion.
///   'rejected'         -> admin declined it. Not shown to tourists;
///                          the owner can edit and resubmit.
class Business {
  const Business({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.name,
    required this.location,
    required this.description,
    required this.phone,
    required this.iconKey,
    required this.status,
    this.imageUrl,
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final String name;
  final String location;
  final String description;
  final String phone;
  final String iconKey;
  final String status;
  final String? imageUrl;

  IconData get icon => placeIconFor(iconKey);
  bool get isApproved => status == 'approved' || status == 'delete_requested';
  bool get isPending => status == 'pending';
  bool get isDeleteRequested => status == 'delete_requested';
  bool get isRejected => status == 'rejected';

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'ownerName': ownerName,
        'name': name,
        'location': location,
        'description': description,
        'phone': phone,
        'icon': iconKey,
        'status': status,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  static Business fromMap(String id, Map<dynamic, dynamic> map) {
    return Business(
      id: id,
      ownerId: map['ownerId']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      iconKey: map['icon']?.toString() ?? kDefaultPlaceIconKey,
      status: map['status']?.toString() ?? 'pending',
      imageUrl: map['imageUrl']?.toString(),
    );
  }

  Business copyWith({String? status}) {
    return Business(
      id: id,
      ownerId: ownerId,
      ownerName: ownerName,
      name: name,
      location: location,
      description: description,
      phone: phone,
      iconKey: iconKey,
      status: status ?? this.status,
      imageUrl: imageUrl,
    );
  }
}

final businessesRef = FirebaseDatabase.instance.ref('businesses');

String businessStatusLabel(String status) {
  switch (status) {
    case 'approved':
      return tr('b_status_approved');
    case 'pending':
      return tr('b_status_pending');
    case 'delete_requested':
      return tr('b_status_delete_requested');
    case 'rejected':
      return tr('b_status_rejected');
    default:
      return status;
  }
}

Color businessStatusColor(String status) {
  switch (status) {
    case 'approved':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'delete_requested':
      return Colors.redAccent;
    case 'rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}