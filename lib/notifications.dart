import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'announcements.dart';
import 'app_settings.dart';
import 'l10n/app_strings.dart';
import 'widgets/app_scaffold.dart';

String _t(String en, String ar) => AppSettings.instance.isArabic ? ar : en;

/// Notifications page: announcements posted by the admin (event updates
/// and general news), newest first. The "Event updates" switch lets a
/// visitor turn event reminders on or off; the choice is remembered on
/// the device. Announcements newer than the last visit show a NEW badge.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const _remindersKey = 'event_reminders';
  static const _lastSeenKey = 'notifications_last_seen';

  bool _eventUpdates = true;
  int _lastSeen = 0;
  int _newestShown = 0;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _saveLastSeen();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _eventUpdates = prefs.getBool(_remindersKey) ?? true;
      _lastSeen = prefs.getInt(_lastSeenKey) ?? 0;
    } catch (_) {}
    if (mounted) setState(() => _prefsLoaded = true);
  }

  Future<void> _saveLastSeen() async {
    if (_newestShown <= 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSeenKey, _newestShown);
    } catch (_) {}
  }

  Future<void> _setEventUpdates(bool value) async {
    setState(() => _eventUpdates = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_remindersKey, value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: tr('notifications'),
      body: !_prefsLoaded
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: announcementsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = parseAnnouncements(snapshot.data?.snapshot.value);
                if (all.isNotEmpty) _newestShown = all.first.createdAt;

                final visible =
                    all.where((a) => _eventUpdates || !a.isEvent).toList();

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        AppCard(
                          child: Row(
                            children: [
                              Icon(Icons.notifications_active,
                                  color: Colors.brown[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _t('Event updates', 'تحديثات الفعاليات'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      _t(
                                        'Get reminders about events and changes',
                                        'تلقَّ تذكيرات حول الفعاليات والتغييرات',
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _eventUpdates,
                                activeColor: Colors.brown[700],
                                onChanged: _setEventUpdates,
                              ),
                            ],
                          ),
                        ),
                        if (visible.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: AppEmptyState(
                              icon: Icons.notifications_none,
                              message: tr('no_notifications_yet'),
                            ),
                          )
                        else
                          for (final a in visible)
                            AppCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.brown[100],
                                    child: Icon(
                                      a.isEvent ? Icons.event : Icons.campaign,
                                      color: Colors.brown[800],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                a.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color:
                                                      context.primaryTextColor,
                                                ),
                                              ),
                                            ),
                                            if (a.createdAt > _lastSeen)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.explorRed,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _t('NEW', 'جديد'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          a.body,
                                          style: TextStyle(
                                            height: 1.4,
                                            color: context.primaryTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          timeAgo(
                                            a.createdAt,
                                            arabic:
                                                AppSettings.instance.isArabic,
                                          ),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: context.mutedTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}