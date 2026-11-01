import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'business.dart';
import 'filter_bar.dart';
import 'l10n/app_strings.dart';
import 'place_details.dart';
import 'place_icons.dart';
import 'widgets/app_scaffold.dart';

/// Events now live in Firebase ('events' node) instead of being
/// hardcoded, so admins can add/edit/remove them from the app. Each
/// event stores BOTH an English and Arabic version of its text, plus
/// a list of "info lines" (Date / Timing / Things To Do, etc.) in
/// both languages, the same shape the original hardcoded content used.
class EventItem {
  const EventItem({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.locationEn,
    required this.locationAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.infoLinesEn,
    required this.infoLinesAr,
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
  final List<String> infoLinesEn;
  final List<String> infoLinesAr;
  final String iconKey;
  final String? imageAsset;
  final String? imageUrl;

  String name(bool arabic) => arabic ? nameAr : nameEn;
  String location(bool arabic) => arabic ? locationAr : locationEn;
  String description(bool arabic) => arabic ? descriptionAr : descriptionEn;
  List<String> infoLines(bool arabic) => arabic ? infoLinesAr : infoLinesEn;
  IconData get icon => placeIconFor(iconKey);

  Map<String, dynamic> toMap() => {
        'name_en': nameEn,
        'name_ar': nameAr,
        'location_en': locationEn,
        'location_ar': locationAr,
        'description_en': descriptionEn,
        'description_ar': descriptionAr,
        'infoLines_en': infoLinesEn,
        'infoLines_ar': infoLinesAr,
        'icon': iconKey,
        if (imageAsset != null) 'imageAsset': imageAsset,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  static List<String> _lines(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  static EventItem fromMap(String id, Map<dynamic, dynamic> map) {
    final linesEn = _lines(map['infoLines_en']);
    final linesAr = _lines(map['infoLines_ar']);

    // Arabic falls back to English when it is missing or empty.
    String ar(String arKey, String enKey) {
      final v = map[arKey]?.toString().trim() ?? '';
      return v.isNotEmpty ? map[arKey].toString() : (map[enKey]?.toString() ?? '');
    }

    return EventItem(
      id: id,
      nameEn: map['name_en']?.toString() ?? '',
      nameAr: ar('name_ar', 'name_en'),
      locationEn: map['location_en']?.toString() ?? '',
      locationAr: ar('location_ar', 'location_en'),
      descriptionEn: map['description_en']?.toString() ?? '',
      descriptionAr: ar('description_ar', 'description_en'),
      infoLinesEn: linesEn,
      infoLinesAr: linesAr.isNotEmpty ? linesAr : linesEn,
      iconKey: map['icon']?.toString() ?? kDefaultPlaceIconKey,
      imageAsset: map['imageAsset']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
    );
  }
}

final eventsRef = FirebaseDatabase.instance.ref('events');

/// Adds the 4 original events to Firebase, but only the ones that
/// aren't already there (checked one by one, by their fixed
/// seed_event_N key) — so it's safe to call every time the page loads.
/// It never touches or overwrites anything else in the node, including
/// events added later through the admin screen.
Future<void> seedEventsIfEmpty() async {
  final allSeeds = <String, Map<String, dynamic>>{
    'seed_event_1': const EventItem(
      id: 'seed_event_1',
      nameEn: 'Muscat Festival',
      nameAr: 'مهرجان مسقط',
      locationEn: 'Muscat',
      locationAr: 'مسقط',
      descriptionEn:
          'Oman welcomes you all to start the new year by exploring the '
          'Muscat night festivals.',
      descriptionAr:
          'ترحب عُمان بالجميع لبدء العام الجديد من خلال استكشاف مهرجانات '
          'مسقط الليلية.',
      infoLinesEn: [
        'Date: The Muscat festival 2026 dates are expected to run from '
            'January to February 2026.',
        'Timing: 4:00 PM - 11:00 PM',
        'Things To Do: Explore the open-air stage shows during the '
            'Muscat night festival, look at the local artefacts and '
            'taste the famous cuisine of Oman.',
      ],
      infoLinesAr: [
        'التاريخ: من المتوقع أن يقام مهرجان مسقط 2026 من يناير إلى '
            'فبراير 2026.',
        'التوقيت: 4:00 مساءً - 11:00 مساءً',
        'الأنشطة: استكشف العروض المسرحية في الهواء الطلق خلال مهرجان '
            'مسقط الليلي، وشاهد الحرف المحلية وتذوق المأكولات العُمانية '
            'الشهيرة.',
      ],
      iconKey: 'celebration',
      imageAsset: 'assets/events/muscat_festival.jpg',
    ).toMap(),
    'seed_event_2': const EventItem(
      id: 'seed_event_2',
      nameEn: 'Salalah Tourism Festival',
      nameAr: 'مهرجان صلالة السياحي',
      locationEn: 'Salalah',
      locationAr: 'صلالة',
      descriptionEn:
          'The Festival is a famous attraction to tourists. This '
          'festival in Salalah has expanded to an international '
          'festival because of the high efforts.',
      descriptionAr:
          'يُعد المهرجان جذبًا مشهورًا للسياح، وقد توسع هذا المهرجان في '
          'صلالة ليصبح مهرجانًا عالميًا بفضل الجهود الكبيرة.',
      infoLinesEn: [
        'Date: Held annually during the Khareef (monsoon) season, '
            'typically July to September.',
        'Timing: Evening hours, from around 4:00 PM until late.',
        'Things To Do: Enjoy cultural pavilions, live music, local '
            'produce markets, and the cool Salalah monsoon weather.',
      ],
      infoLinesAr: [
        'التاريخ: يُقام سنويًا خلال موسم الخريف، عادةً من يوليو إلى '
            'سبتمبر.',
        'التوقيت: ساعات المساء، من حوالي الرابعة عصرًا حتى وقت متأخر.',
        'الأنشطة: استمتع بالأجنحة الثقافية والموسيقى الحية وأسواق '
            'المنتجات المحلية وأجواء الخريف الباردة في صلالة.',
      ],
      iconKey: 'cloud',
      imageAsset: 'assets/events/salalah_tourism_festival.jpg',
    ).toMap(),
    'seed_event_3': const EventItem(
      id: 'seed_event_3',
      nameEn: 'Muscat International Book Fair',
      nameAr: 'معرض مسقط الدولي للكتاب',
      locationEn: 'Muscat',
      locationAr: 'مسقط',
      descriptionEn:
          'Get to see books related to Omani heritage and history, '
          'which further contribute to enhancing cultural understanding.',
      descriptionAr:
          'تعرف على الكتب المتعلقة بالتراث والتاريخ العُماني، مما يسهم '
          'في تعزيز الفهم الثقافي.',
      infoLinesEn: [
        'Date: Usually held in February each year.',
        'Timing: Daily, morning through evening.',
        'Things To Do: Browse regional and international publishers, '
            'attend author talks, and pick up books on Omani history '
            'and culture.',
      ],
      infoLinesAr: [
        'التاريخ: يُقام عادةً في فبراير من كل عام.',
        'التوقيت: يوميًا، من الصباح حتى المساء.',
        'الأنشطة: تصفح إصدارات دور النشر المحلية والعالمية، واحضر '
            'لقاءات مع المؤلفين، واقتنِ كتبًا عن تاريخ عُمان وثقافتها.',
      ],
      iconKey: 'menu_book',
      imageAsset: 'assets/events/muscat_book_fair.jpg',
    ).toMap(),
    'seed_event_4': const EventItem(
      id: 'seed_event_4',
      nameEn: 'Oman Marathon 2026',
      nameAr: 'ماراثون عُمان 2026',
      locationEn: 'Muscat',
      locationAr: 'مسقط',
      descriptionEn:
          'Escape to Oman Marathon blended with adventures, vibrant '
          'coastal views making it a perfect event for runners and '
          'creates a memorable journey.',
      descriptionAr:
          'اهرب إلى ماراثون عُمان الممزوج بالمغامرة والإطلالات الساحلية '
          'النابضة بالحياة، مما يجعله فعالية مثالية للعدائين ويخلق '
          'رحلة لا تُنسى.',
      infoLinesEn: [
        'Date: Typically held in January.',
        'Timing: Early morning start, around 6:00 AM.',
        'Things To Do: Run the coastal course, cheer at the finish '
            'line festival, or join the family fun-run.',
      ],
      infoLinesAr: [
        'التاريخ: يُقام عادةً في يناير.',
        'التوقيت: بداية مبكرة في الصباح، حوالي الساعة 6:00 صباحًا.',
        'الأنشطة: اركض على المسار الساحلي، احتفل عند خط النهاية، أو '
            'شارك في سباق الجري العائلي.',
      ],
      iconKey: 'directions_run',
      imageAsset: 'assets/events/oman_marathon.jpg',
    ).toMap(),
  };

  final snapshot = await eventsRef.get();
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

  await eventsRef.update(missing);
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _location;
  String? _type;
  bool _filtersOpen = false;

  // Note: seeding the original events is done from the Admin Dashboard
  // (see admin_home.dart), not here. Tourist accounts only have read
  // access to the 'events' node, so a write attempted from this page
  // would silently fail under Firebase's security rules.

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
          title: tr('events'),
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
                    hintText: tr('search_events_hint'),
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
                  stream: eventsRef.onValue,
                  builder: (context, eventSnapshot) {
                    if (eventSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final eventValue = eventSnapshot.data?.snapshot.value;
                    final events = <EventItem>[];

                    if (eventValue is Map) {
                      for (final entry in eventValue.entries) {
                        if (entry.value is Map) {
                          events.add(
                            EventItem.fromMap(
                              entry.key.toString(),
                              entry.value as Map,
                            ),
                          );
                        }
                      }
                    }

                    // Approved local businesses are shown mixed in here,
                    // alongside real events — see business.dart. This
                    // never touches the 'events' node or the Destinations
                    // /Explore page at all.
                    return StreamBuilder<DatabaseEvent>(
                      stream: businessesRef.onValue,
                      builder: (context, bizSnapshot) {
                        final bizValue = bizSnapshot.data?.snapshot.value;
                        final businesses = <Business>[];

                        if (bizValue is Map) {
                          for (final entry in bizValue.entries) {
                            if (entry.value is Map) {
                              final b = Business.fromMap(
                                entry.key.toString(),
                                entry.value as Map,
                              );
                              if (b.status == 'approved' ||
                                  b.status == 'delete_requested') {
                                businesses.add(b);
                              }
                            }
                          }
                        }

                        final items = <_EventOrBusiness>[
                          ...events.map(_EventOrBusiness.event),
                          ...businesses.map(_EventOrBusiness.business),
                        ];

                        final locations = locationOptions(
                          items.map((i) => i.location(arabic)),
                        );
                        final types = typeOptions(items.map((i) => i.iconKey));

                        // A selected filter that no longer exists (e.g.
                        // after switching language) is treated as "All".
                        final activeLocation =
                            locations.any((o) => o.value == _location)
                                ? _location
                                : null;
                        final activeType =
                            types.any((o) => o.value == _type) ? _type : null;

                        final filtered = items.where((item) {
                          if (activeLocation != null &&
                              item.location(arabic).trim() !=
                                  activeLocation) {
                            return false;
                          }
                          if (activeType != null &&
                              item.iconKey != activeType) {
                            return false;
                          }
                          if (_query.isEmpty) return true;
                          final q = _query.toLowerCase();
                          return item.name(arabic).toLowerCase().contains(q) ||
                              item
                                  .location(arabic)
                                  .toLowerCase()
                                  .contains(q);
                        }).toList();

                        final empty = AppEmptyState(
                          icon: Icons.event_busy,
                          message: tr('no_events_match'),
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
                            final item = filtered[index];
                            return PlaceCard(
                              name: item.name(arabic),
                              location: item.location(arabic),
                              description: item.description(arabic),
                              icon: item.icon,
                              imageAsset: item.imageAsset,
                              imageUrl: item.imageUrl,
                              onExplore: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlaceDetailsPage(
                                      name: item.name(arabic),
                                      icon: item.icon,
                                      infoLines: item.infoLines(arabic),
                                      imageAsset: item.imageAsset,
                                      imageUrl: item.imageUrl,
                                      location: item.location(arabic),
                                      trackType: item.trackType,
                                      trackId: item.trackId,
                                      trackName: item.trackName,
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
                                onChanged: (v) =>
                                    setState(() => _location = v),
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

/// Lets the grid above render an [EventItem] and an approved [Business]
/// through the same card code, without changing either model. A
/// business has no separate EN/AR text (it's the owner's own words),
/// so its name/location/description are shown as-is in both languages.
class _EventOrBusiness {
  const _EventOrBusiness._({this.event, this.business});

  factory _EventOrBusiness.event(EventItem e) => _EventOrBusiness._(event: e);
  factory _EventOrBusiness.business(Business b) =>
      _EventOrBusiness._(business: b);

  final EventItem? event;
  final Business? business;

  String name(bool arabic) => event?.name(arabic) ?? business?.name ?? '';
  String location(bool arabic) =>
      event?.location(arabic) ?? business?.location ?? '';
  String description(bool arabic) =>
      event?.description(arabic) ?? business?.description ?? '';
  IconData get icon => event?.icon ?? business!.icon;
  String get iconKey => event?.iconKey ?? business!.iconKey;
  String get trackType => event != null ? 'event' : 'business';
  String get trackId => event?.id ?? business!.id;
  String get trackName => event?.nameEn ?? business!.name;
  String? get imageAsset => event?.imageAsset;
  String? get imageUrl => event?.imageUrl ?? business?.imageUrl;

  List<String> infoLines(bool arabic) {
    if (event != null) return event!.infoLines(arabic);
    final b = business!;
    return [
      tr('e_local_business'),
      if (b.phone.isNotEmpty) '${tr('e_phone_label')} ${b.phone}',
    ];
  }
}