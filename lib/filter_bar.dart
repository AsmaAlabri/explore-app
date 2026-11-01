import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'place_icons.dart';

/// Small helper for the filter chips shown under the search bar on the
/// Destinations and Events pages. Texts are translated here directly
/// (instead of through l10n/app_strings.dart) so adding filters doesn't
/// require touching the main translation table.
String _t(String en, String ar) => AppSettings.instance.isArabic ? ar : en;

String filterAllLabel() => _t('All', 'الكل');

/// Readable name for a place/event icon key, used as its "type" filter.
String placeTypeLabel(String iconKey) {
  switch (iconKey) {
    case 'museum':
      return _t('Museum', 'متحف');
    case 'landscape':
      return _t('Nature', 'طبيعة');
    case 'fort':
      return _t('Fort', 'حصن');
    case 'mosque':
      return _t('Mosque', 'مسجد');
    case 'celebration':
      return _t('Celebration', 'احتفال');
    case 'cloud':
      return _t('Seasonal', 'موسمي');
    case 'menu_book':
      return _t('Books', 'كتب');
    case 'directions_run':
      return _t('Sports', 'رياضة');
    case 'star':
      return _t('Featured', 'مميز');
    case 'beach_access':
      return _t('Beach', 'شاطئ');
    case 'terrain':
      return _t('Mountains', 'جبال');
    case 'restaurant':
      return _t('Food', 'مأكولات');
    case 'hiking':
      return _t('Hiking', 'مشي');
    case 'photo_camera':
      return _t('Photography', 'تصوير');
    case 'festival':
      return _t('Festival', 'مهرجان');
    case 'local_activity':
      return _t('Activity', 'نشاط');
    case 'water':
      return _t('Water', 'مياه');
    default:
      return _t('Place', 'مكان');
  }
}

class FilterOption {
  const FilterOption(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

/// Builds the "type" options (one per distinct icon key in [iconKeys]).
List<FilterOption> typeOptions(Iterable<String> iconKeys) {
  final keys = iconKeys.toSet().toList()
    ..sort((a, b) => placeTypeLabel(a).compareTo(placeTypeLabel(b)));
  return keys
      .map((k) => FilterOption(k, placeTypeLabel(k), placeIconFor(k)))
      .toList();
}

/// Builds the "location" options (one per distinct non-empty location).
List<FilterOption> locationOptions(Iterable<String> locations) {
  final list = locations
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return list
      .map((l) => FilterOption(l, l, Icons.location_on_outlined))
      .toList();
}

/// One horizontally scrolling row of chips: "All" followed by [options].
/// [selected] is null when "All" is chosen.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<FilterOption> options;
  final String? selected;
  final ValueChanged<String?> onChanged;

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return ChoiceChip(
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.brown[800],
            ),
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.brown[900],
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: Colors.brown[800],
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.brown[700]!),
      onSelected: (_) => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(
            label: filterAllLabel(),
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final option in options) ...[
            const SizedBox(width: 8),
            _chip(
              label: option.label,
              icon: option.icon,
              isSelected: selected == option.value,
              onTap: () => onChanged(option.value),
            ),
          ],
        ],
      ),
    );
  }
}

/// Square button shown next to the search box. Tapping it shows/hides the
/// filter chips. A small dot appears on it while a filter is active so
/// people know the list is filtered even when the chips are hidden.
class FilterToggleButton extends StatelessWidget {
  const FilterToggleButton({
    super.key,
    required this.isOpen,
    required this.hasActiveFilter,
    required this.onTap,
  });

  final bool isOpen;
  final bool hasActiveFilter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _t('Filters', 'تصفية'),
      child: Material(
        color: isOpen ? Colors.brown[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.brown[700]!, width: 1.4),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune,
                  color: isOpen ? Colors.white : Colors.brown[800],
                ),
                if (hasActiveFilter)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isOpen ? Colors.brown[800]! : Colors.white,
                          width: 1.2,
                        ),
                      ),
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