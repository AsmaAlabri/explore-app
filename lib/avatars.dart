import 'package:flutter/material.dart';

/// A small built-in set of avatar options (icon + color), so users can
/// personalize their profile without needing photo upload / storage
/// infrastructure.
class AppAvatar {
  const AppAvatar({
    required this.id,
    required this.icon,
    required this.color,
  });

  final String id;
  final IconData icon;
  final Color color;
}

const List<AppAvatar> kAvatars = [
  AppAvatar(id: 'avatar_brown', icon: Icons.person, color: Colors.brown),
  AppAvatar(id: 'avatar_teal', icon: Icons.person, color: Colors.teal),
  AppAvatar(id: 'avatar_indigo', icon: Icons.person, color: Colors.indigo),
  AppAvatar(id: 'avatar_orange', icon: Icons.person, color: Colors.deepOrange),
  AppAvatar(id: 'avatar_purple', icon: Icons.person, color: Colors.purple),
  AppAvatar(id: 'avatar_green', icon: Icons.person, color: Colors.green),
  AppAvatar(id: 'avatar_pink', icon: Icons.face_3, color: Colors.pink),
  AppAvatar(id: 'avatar_blue', icon: Icons.face_6, color: Colors.blue),
];

const String kDefaultAvatarId = 'avatar_brown';

/// Looks up an avatar by its saved id, falling back to the default
/// avatar if the id is missing or unrecognized (e.g. never set yet).
AppAvatar avatarById(String? id) {
  if (id == null) {
    return kAvatars.first;
  }

  for (final avatar in kAvatars) {
    if (avatar.id == id) {
      return avatar;
    }
  }

  return kAvatars.first;
}