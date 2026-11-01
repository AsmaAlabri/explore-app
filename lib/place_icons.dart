import 'package:flutter/material.dart';

/// Firebase can only store simple values, not an IconData object, so
/// every Destination/Event stores an icon by NAME (a key into this
/// map) instead. Add a new entry here any time a new icon is needed
/// in the admin "add destination/event" forms.
const Map<String, IconData> placeIcons = {
  'museum': Icons.museum,
  'landscape': Icons.landscape,
  'fort': Icons.fort,
  'mosque': Icons.mosque,
  'celebration': Icons.celebration,
  'cloud': Icons.cloud,
  'menu_book': Icons.menu_book,
  'directions_run': Icons.directions_run,
  'place': Icons.place,
  'star': Icons.star,
  'beach_access': Icons.beach_access,
  'terrain': Icons.terrain,
  'restaurant': Icons.restaurant,
  'hiking': Icons.hiking,
  'photo_camera': Icons.photo_camera,
  'festival': Icons.festival,
  'local_activity': Icons.local_activity,
  'water': Icons.water,
};

const String kDefaultPlaceIconKey = 'place';

IconData placeIconFor(String? key) {
  if (key == null) return placeIcons[kDefaultPlaceIconKey]!;
  return placeIcons[key] ?? placeIcons[kDefaultPlaceIconKey]!;
}