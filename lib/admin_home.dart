import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'all_feedback.dart';
import 'events.dart';
import 'explore.dart';
import 'home.dart';
import 'manage_businesses.dart';
import 'manage_destinations.dart';
import 'manage_events.dart';
import 'manage_users.dart';
import 'welcome.dart';

/// Landing page for anyone who signs in through Admin Login. Lists
/// the admin-only tools as tiles. Tools not built yet show a
/// "coming soon" message instead of crashing on a missing page.
///
/// Also seeds the original 4 destinations and 4 events into Firebase
/// the moment the dashboard opens — this has to happen here (under the
/// admin's write permission), not on the tourist-facing Explore/Events
/// pages, since tourist accounts can only read those nodes.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
    seedDestinationsIfEmpty();
    seedEventsIfEmpty();
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EE),
      appBar: AppBar(
        backgroundColor: Colors.brown[900],
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'View app as tourist',
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () {
              // push (not pushReplacement) — this keeps the Admin
              // Dashboard underneath, so the floating button below
              // can pop back to it.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _TouristPreview(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await FirebaseAuth.instance.signOut();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomePage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.05,
            children: [
              _AdminTile(
                icon: Icons.people_alt,
                label: 'Manage Users',
                subtitle: 'Roles & business approval',
                color: Colors.brown[800]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersPage()),
                ),
              ),
              _AdminTile(
                icon: Icons.reviews,
                label: 'All Feedback',
                subtitle: 'Every rating & comment',
                color: Colors.brown[700]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllFeedbackPage()),
                ),
              ),
              _AdminTile(
                icon: Icons.map,
                label: 'Manage Destinations',
                subtitle: 'Add / edit / remove places',
                color: Colors.brown[600]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageDestinationsPage(),
                  ),
                ),
              ),
              _AdminTile(
                icon: Icons.event,
                label: 'Manage Events',
                subtitle: 'Add / edit / remove events',
                color: Colors.brown[500]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageEventsPage()),
                ),
              ),
              _AdminTile(
                icon: Icons.storefront,
                label: 'Manage Businesses',
                subtitle: 'Approve / edit / remove listings',
                color: Colors.brown[300]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageBusinessesPage(),
                  ),
                ),
              ),
              _AdminTile(
                icon: Icons.bar_chart,
                label: 'Analytics',
                subtitle: 'Usage insights & charts',
                color: Colors.brown[400]!,
                onTap: () => _comingSoon(context, 'Analytics dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps the normal tourist Home page with a floating "Back to Admin"
/// button, so admins can preview the app as a tourist sees it and
/// then return to the Admin Dashboard (which is still underneath on
/// the navigation stack, since we got here via Navigator.push).
///
/// The tourist side runs in its OWN nested Navigator, not the app's
/// main one. Without this, something like the drawer's "Home" button
/// (which clears the whole navigation stack back to Home) would also
/// wipe out the hidden Admin Dashboard route underneath, leaving the
/// "Back to Admin" button with nothing to return to. With its own
/// Navigator, anything that happens while browsing as a tourist here
/// — Home, logout, going back — stays contained inside the preview,
/// and the real Admin Dashboard route is never touched.
class _TouristPreview extends StatelessWidget {
  const _TouristPreview();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[900],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back to Admin'),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 34),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}