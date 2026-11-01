import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../about_oman.dart';
import '../about_us.dart';
import '../events.dart';
import '../explore.dart';
import '../help_support.dart';
import '../home.dart';
import '../l10n/app_strings.dart';
import '../my_business.dart';
import '../notifications.dart';
import '../profile.dart';
import '../welcome.dart';
import 'app_scaffold.dart';

/// Shared navigation drawer used by every page reachable from Home
/// (Home, About Oman, Explore, Events, Notifications, ...) so the
/// hamburger menu is consistent and actually opens everywhere, not
/// just on the Home page.
///
/// IMPORTANT: never instantiate this with `const AppNavigationDrawer()`
/// inside a page that needs to reflect language changes — a const
/// instance is reused as-is by Flutter and will not rebuild with the
/// new translations. Always write `AppNavigationDrawer()` (no const).
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  /// "My Business" only shows up for accounts whose role is
  /// 'business_owner' — everyone else (tourists, admins previewing as
  /// tourist) sees nothing extra here. A single one-time role lookup,
  /// not a live listener, so it doesn't add any ongoing Firebase cost.
  Widget _businessOwnerItem(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return FutureBuilder<DataSnapshot>(
      future: FirebaseDatabase.instance.ref('users/$uid/role').get(),
      builder: (context, snapshot) {
        final role = snapshot.data?.value?.toString();
        if (role != 'business_owner') return const SizedBox.shrink();

        return _item(
          context,
          icon: Icons.storefront,
          title: tr('e_my_business'),
          onTap: () => _openPage(context, const MyBusinessPage()),
        );
      },
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: context.primaryTextColor,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Drawer(
      child: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bg.jpg', fit: BoxFit.cover),
          ),
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.82)
                : Colors.white.withOpacity(0.85),
          ),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Icon(
                    Icons.menu,
                    size: 35,
                    color: context.primaryTextColor,
                  ),
                ),
              ),
              _item(
                context,
                icon: Icons.home,
                title: tr('home'),
                onTap: () => _goHome(context),
              ),
              _item(
                context,
                icon: Icons.music_note,
                title: tr('about_oman'),
                onTap: () => _openPage(context, const AboutOmanPage()),
              ),
              _item(
                context,
                icon: Icons.explore,
                title: tr('explore'),
                onTap: () => _openPage(context, const ExplorePage()),
              ),
              _item(
                context,
                icon: Icons.event,
                title: tr('events'),
                onTap: () => _openPage(context, const EventsPage()),
              ),
              _businessOwnerItem(context),
              _item(
                context,
                icon: Icons.notifications,
                title: tr('notifications'),
                onTap: () => _openPage(context, const NotificationsPage()),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.brown),
                title: Text(
                  tr('profile_settings'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.primaryTextColor,
                  ),
                ),
                onTap: () => _openPage(context, const ProfilePage()),
              ),
              _item(
                context,
                icon: Icons.help,
                title: tr('help_support'),
                onTap: () => _openPage(context, const HelpSupportPage()),
              ),
              _item(
                context,
                icon: Icons.info,
                title: tr('about_us'),
                onTap: () => _openPage(context, const AboutUsPage()),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  tr('logout'),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}