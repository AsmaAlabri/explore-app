import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'filter_bar.dart';
import 'l10n/app_strings.dart';
import 'place_details.dart';
import 'place_icons.dart';
import 'widgets/app_scaffold.dart';

/// Destinations now live in Firebase ('destinations' node) instead of
/// being hardcoded, so admins can add/edit/remove them from the app.
/// Each destination stores BOTH an English and an Arabic version of
/// its text (name_en/name_ar, etc.) so it still translates properly,
/// the same way the original hardcoded content did.
class Destination {
  const Destination({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.locationEn,
    required this.locationAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.detailsEn,
    required this.detailsAr,
    required this.iconKey,
    this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String locationEn;
  final String locationAr;
  final String descriptionEn;
  final String descriptionAr;
  final String detailsEn;
  final String detailsAr;
  final String iconKey;
  final String? imageAsset;
  final String? imageUrl;

  String name(bool arabic) => arabic ? nameAr : nameEn;
  String location(bool arabic) => arabic ? locationAr : locationEn;
  String description(bool arabic) => arabic ? descriptionAr : descriptionEn;
  String details(bool arabic) => arabic ? detailsAr : detailsEn;
  IconData get icon => placeIconFor(iconKey);

  Map<String, dynamic> toMap() => {
        'name_en': nameEn,
        'name_ar': nameAr,
        'location_en': locationEn,
        'location_ar': locationAr,
        'description_en': descriptionEn,
        'description_ar': descriptionAr,
        'details_en': detailsEn,
        'details_ar': detailsAr,
        'icon': iconKey,
        if (imageAsset != null) 'imageAsset': imageAsset,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  static Destination fromMap(String id, Map<dynamic, dynamic> map) {
    // Arabic falls back to English when it is missing or empty.
    String ar(String arKey, String enKey) {
      final v = map[arKey]?.toString().trim() ?? '';
      return v.isNotEmpty ? map[arKey].toString() : (map[enKey]?.toString() ?? '');
    }

    return Destination(
      id: id,
      nameEn: map['name_en']?.toString() ?? '',
      nameAr: ar('name_ar', 'name_en'),
      locationEn: map['location_en']?.toString() ?? '',
      locationAr: ar('location_ar', 'location_en'),
      descriptionEn: map['description_en']?.toString() ?? '',
      descriptionAr: ar('description_ar', 'description_en'),
      detailsEn: map['details_en']?.toString() ?? '',
      detailsAr: ar('details_ar', 'details_en'),
      iconKey: map['icon']?.toString() ?? kDefaultPlaceIconKey,
      imageAsset: map['imageAsset']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
    );
  }
}

final destinationsRef = FirebaseDatabase.instance.ref('destinations');

/// Adds the 4 original destinations to Firebase, but only the ones
/// that aren't already there (checked one by one, by their fixed
/// seed_dest_N key) — so it's safe to call every time the page loads.
/// It never touches or overwrites anything else in the node, including
/// destinations added later through the admin screen.
Future<void> seedDestinationsIfEmpty() async {
  final allSeeds = <String, Map<String, dynamic>>{
    'seed_dest_1': const Destination(
      id: 'seed_dest_1',
      nameEn: 'Oman Across Ages Museum',
      nameAr: 'متحف عُمان عبر العصور',
      locationEn: 'Manah',
      locationAr: 'منح',
      descriptionEn:
          "Discover Oman's rich legacy through immersive exhibits and "
          'cultural artifacts dating back thousands of years.',
      descriptionAr:
          'اكتشف تراث عُمان الغني من خلال معارض تفاعلية وقطع أثرية ثقافية '
          'يعود تاريخها إلى آلاف السنين.',
      detailsEn:
          "Wilayat Manah's Oman Across Ages Museum provides guests with an "
          "enthralling voyage through the country's rich natural "
          "heritage, history, and culture. The museum's interactive "
          'displays and state-of-the-art technologies are intended to '
          'captivate visitors of all ages, bringing '
          "Oman's history to life in a distinctive and unforgettable way.",
      detailsAr:
          'يقدم متحف عُمان عبر العصور في ولاية منح للزوار رحلة آسرة عبر '
          'تراث البلاد الطبيعي وتاريخها وثقافتها الغنية. صُممت العروض '
          'التفاعلية والتقنيات الحديثة في المتحف لجذب الزوار من جميع '
          'الأعمار، مما يعيد تاريخ عُمان إلى الحياة بطريقة مميزة لا تُنسى.',
      iconKey: 'museum',
      imageAsset: 'assets/destinations/oman_across_ages_museum.jpg',
    ).toMap(),
    'seed_dest_2': const Destination(
      id: 'seed_dest_2',
      nameEn: 'Bar Al Hikman',
      nameAr: 'بر الحكمان',
      locationEn: 'Al Wusta',
      locationAr: 'الوسطى',
      descriptionEn:
          "Bar Al Hikman is an island located in the center of Oman's "
          'coast and is considered to be one of the most important bird '
          'migration...',
      descriptionAr:
          'بر الحكمان جزيرة تقع في وسط ساحل عُمان، وتُعد من أهم مواقع '
          'هجرة الطيور...',
      detailsEn:
          'Bar Al Hikman is a vast coastal wetland and peninsula on the '
          'Arabian Sea, renowned as one of the most important migratory '
          'bird stopover sites in the Middle East, hosting hundreds of '
          'thousands of shorebirds each year.',
      detailsAr:
          'بر الحكمان هو أرض رطبة ساحلية شاسعة وشبه جزيرة على بحر العرب، '
          'تشتهر بكونها واحدة من أهم محطات توقف الطيور المهاجرة في الشرق '
          'الأوسط، حيث تستقبل مئات الآلاف من طيور الشواطئ كل عام.',
      iconKey: 'landscape',
      imageAsset: 'assets/destinations/bar_al_hikman.jpg',
    ).toMap(),
    'seed_dest_3': const Destination(
      id: 'seed_dest_3',
      nameEn: 'Nizwa Fort',
      nameAr: 'حصن نزوى',
      locationEn: 'Ad Dakhiliyah',
      locationAr: 'الداخلية',
      descriptionEn:
          'Nizwa Fort, the largest of its kind in the Arabian Peninsula, '
          'is a massive circular stronghold built from mud by Imam '
          'Sultan bin Saif Al-...',
      descriptionAr:
          'حصن نزوى، أكبر حصن من نوعه في شبه الجزيرة العربية، هو معقل '
          'دائري ضخم بناه الإمام سلطان بن سيف...',
      detailsEn:
          "Nizwa Fort was built in the 17th century and is one of Oman's "
          'most visited national monuments, famous for its massive '
          'circular tower, defensive design, and sweeping views over '
          'Nizwa and the surrounding date palm oasis.',
      detailsAr:
          'بُني حصن نزوى في القرن السابع عشر، وهو أحد أكثر المعالم '
          'الوطنية زيارةً في عُمان، ويشتهر ببرجه الدائري الضخم وتصميمه '
          'الدفاعي وإطلالاته الخلابة على نزوى وواحة النخيل المحيطة بها.',
      iconKey: 'fort',
      imageAsset: 'assets/destinations/nizwa_fort.jpg',
    ).toMap(),
    'seed_dest_4': const Destination(
      id: 'seed_dest_4',
      nameEn: 'Sultan Qaboos Grand Mosque',
      nameAr: 'جامع السلطان قابوس الأكبر',
      locationEn: 'Muscat',
      locationAr: 'مسقط',
      descriptionEn:
          'Sultan Qaboos Grand Mosque is one of the most recognizable '
          'architectural and religious landmarks in Oman.',
      descriptionAr:
          'جامع السلطان قابوس الأكبر هو أحد أبرز المعالم المعمارية '
          'والدينية في عُمان.',
      detailsEn:
          'Completed in 2001, the Grand Mosque can hold up to 20,000 '
          'worshippers and is known for its enormous hand-woven Persian '
          'carpet and one of the largest single-piece chandeliers in '
          'the world.',
      detailsAr:
          'اكتمل بناء الجامع الأكبر عام 2001، ويتسع لأكثر من 20,000 '
          'مصلٍ، ويشتهر بسجادته الفارسية الضخمة المصنوعة يدويًا وواحدة '
          'من أكبر الثريات ذات القطعة الواحدة في العالم.',
      iconKey: 'mosque',
      imageAsset: 'assets/destinations/sultan_qaboos_grand_mosque.jpg',
    ).toMap(),
  };

  final snapshot = await destinationsRef.get();
  final existingKeys = <String>{};
  final value = snapshot.value;
  if (value is Map) {
    existingKeys.addAll(value.keys.map((k) => k.toString()));
  }

  final missing = <String, Map<String, dynamic>>{};
  for (final entry in allSeeds.entries) {
    if (!existingKeys.contains(entry.key)) {
      missing[entry.key] = entry.value;
    }
  }

  if (missing.isEmpty) return;

  await destinationsRef.update(missing);
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _location;
  String? _type;
  bool _filtersOpen = false;

  // Note: seeding the original destinations is done from the Admin
  // Dashboard (see admin_home.dart), not here. Tourist accounts only
  // have read access to the 'destinations' node, so a write attempted
  // from this page would silently fail under Firebase's security rules.

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final arabic = AppSettings.instance.isArabic;

        return ListScaffold(
          title: tr('destinations_title'),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: tr('search_destination_hint'),
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: Icon(Icons.search, color: Colors.brown[800]),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.brown[700]!, width: 1.4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.brown[700]!, width: 1.4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.brown[900]!, width: 2),
                    ),
                  ),
                ),
                    ),
                    const SizedBox(width: 8),
                    FilterToggleButton(
                      isOpen: _filtersOpen,
                      hasActiveFilter: _location != null || _type != null,
                      onTap: () =>
                          setState(() => _filtersOpen = !_filtersOpen),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
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
                            Destination.fromMap(
                              entry.key.toString(),
                              entry.value as Map,
                            ),
                          );
                        }
                      }
                    }

                    final locations = locationOptions(
                      destinations.map((d) => d.location(arabic)),
                    );
                    final types = typeOptions(destinations.map((d) => d.iconKey));

                    // A selected filter that no longer exists (e.g. after
                    // switching language) is treated as "All".
                    final activeLocation =
                        locations.any((o) => o.value == _location)
                            ? _location
                            : null;
                    final activeType =
                        types.any((o) => o.value == _type) ? _type : null;

                    final filtered = destinations.where((d) {
                      if (activeLocation != null &&
                          d.location(arabic).trim() != activeLocation) {
                        return false;
                      }
                      if (activeType != null && d.iconKey != activeType) {
                        return false;
                      }
                      if (_query.isEmpty) return true;
                      final q = _query.toLowerCase();
                      return d.name(arabic).toLowerCase().contains(q) ||
                          d.location(arabic).toLowerCase().contains(q);
                    }).toList();

                    final empty = AppEmptyState(
                      icon: Icons.search_off,
                      message: tr('no_destinations_match'),
                    );

                    final grid = GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final place = filtered[index];
                        return PlaceCard(
                          name: place.name(arabic),
                          location: place.location(arabic),
                          description: place.description(arabic),
                          icon: place.icon,
                          imageAsset: place.imageAsset,
                          imageUrl: place.imageUrl,
                          onExplore: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaceDetailsPage(
                                  name: place.name(arabic),
                                  icon: place.icon,
                                  description: place.details(arabic),
                                  imageAsset: place.imageAsset,
                                  imageUrl: place.imageUrl,
                                  location: place.location(arabic),
                                  trackType: 'destination',
                                  trackId: place.id,
                                  trackName: place.nameEn,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );

                    return Column(
                      children: [
                        if (_filtersOpen && locations.length > 1)
                          FilterChipsRow(
                            options: locations,
                            selected: activeLocation,
                            onChanged: (v) => setState(() => _location = v),
                          ),
                        if (_filtersOpen && types.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: FilterChipsRow(
                              options: types,
                              selected: activeType,
                              onChanged: (v) => setState(() => _type = v),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Expanded(child: filtered.isEmpty ? empty : grid),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}