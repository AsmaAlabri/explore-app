import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_settings.dart';
import 'widgets/app_scaffold.dart';

/// "Get Directions" and "Nearby" buttons for the place details page.
///
/// Both hand off to Google Maps (no API key or location permission needed
/// inside the app): Directions starts a route to the place from the
/// visitor's current location, and Nearby searches Google Maps for a
/// chosen category (restaurants, hotels, ...) around the place.
String _t(String en, String ar) => AppSettings.instance.isArabic ? ar : en;

String _placeQuery(String name, String? location) {
  final loc = (location != null && location.isNotEmpty) ? ', $location' : '';
  return '$name$loc, Oman';
}

Future<void> _open(BuildContext context, Uri url) async {
  final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_t('Could not open the map.', 'تعذر فتح الخريطة.'))),
    );
  }
}

Future<void> openDirections(
  BuildContext context,
  String name,
  String? location,
) {
  final destination = Uri.encodeComponent(_placeQuery(name, location));
  return _open(
    context,
    Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destination',
    ),
  );
}

Future<void> openNearby(
  BuildContext context,
  String category,
  String name,
  String? location,
) {
  final query = Uri.encodeComponent('$category near ${_placeQuery(name, location)}');
  return _open(
    context,
    Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
  );
}

class _NearbyCategory {
  const _NearbyCategory(this.query, this.en, this.ar, this.icon);

  final String query;
  final String en;
  final String ar;
  final IconData icon;
}

const _categories = <_NearbyCategory>[
  _NearbyCategory('restaurants', 'Restaurants', 'مطاعم', Icons.restaurant),
  _NearbyCategory('cafes', 'Cafes', 'مقاهي', Icons.local_cafe),
  _NearbyCategory('hotels', 'Hotels', 'فنادق', Icons.hotel),
  _NearbyCategory(
    'gas stations',
    'Fuel stations',
    'محطات وقود',
    Icons.local_gas_station,
  ),
  _NearbyCategory('ATM', 'ATMs', 'صرافات آلية', Icons.atm),
  _NearbyCategory('pharmacies', 'Pharmacies', 'صيدليات', Icons.local_pharmacy),
];

Future<void> showNearbySheet(
  BuildContext context,
  String name,
  String? location,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Text(
                _t('Find nearby', 'ابحث بالقرب'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[900],
                ),
              ),
            ),
            for (final c in _categories)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.brown[100],
                  child: Icon(c.icon, color: Colors.brown[800]),
                ),
                title: Text(_t(c.en, c.ar)),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {
                  Navigator.pop(sheetContext);
                  openNearby(context, c.query, name, location);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class NearbyActionsRow extends StatelessWidget {
  const NearbyActionsRow({super.key, required this.name, this.location});

  final String name;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: context.primaryTextColor,
      side: BorderSide(color: context.secondaryTextColor),
      padding: const EdgeInsets.symmetric(vertical: 14),
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => openDirections(context, name, location),
            icon: const Icon(Icons.directions_outlined),
            label: Text(_t('Directions', 'الاتجاهات')),
            style: style,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => showNearbySheet(context, name, location),
            icon: const Icon(Icons.near_me_outlined),
            label: Text(_t('Nearby', 'بالقرب')),
            style: style,
          ),
        ),
      ],
    );
  }
}