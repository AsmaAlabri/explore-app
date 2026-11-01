import 'package:flutter/material.dart';

import '../help_support.dart';
import '../l10n/app_strings.dart';
import 'app_drawer.dart';

/// Brand colors pulled from the prototype.
class AppColors {
  static const brown = Colors.brown;
  static const explorRed = Color(0xFFB3261E); // "Explore More" button red
  static const starGold = Color(0xFFFFC107);
  static const pinMaroon = Color(0xFF8B2E2E);
  static const cardBg = Colors.white;
  static const listScreenBg = Color(0xFFF3F1EE); // light warm gray/white
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkBackground = Color(0xFF121212);
}

/// Small helpers so widgets can pick a light/dark-appropriate color
/// with one line instead of hardcoding a color that ignores the
/// theme. Use these anywhere a background, card, or text color was
/// previously a bare Colors.xxx value.
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Translucent card placed over a photo background.
  Color get cardSurfaceColor =>
      isDark ? Colors.black.withOpacity(0.75) : Colors.white.withOpacity(0.92);

  /// Solid card/list-item background on a plain (non-photo) page.
  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.cardBg;

  /// Full-page background for plain (non-photo) list pages.
  Color get listBackgroundColor =>
      isDark ? AppColors.darkBackground : AppColors.listScreenBg;

  Color get primaryTextColor => isDark ? Colors.white : Colors.black87;
  Color get secondaryTextColor => isDark ? Colors.white70 : Colors.black54;
  Color get mutedTextColor => isDark ? Colors.white54 : Colors.black45;
}

/// Shared scaffold used by pages that have the full-bleed background
/// photo + dark overlay look (Welcome, Home, About Oman, Feedback,
/// Notifications, ...).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.overlayOpacity = 0.55,
    this.showBackButton = false,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final double overlayOpacity;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pages reached by pushing (Feedback) get a back button and no
      // drawer; pages reached from the drawer itself (About Oman,
      // Notifications) get the hamburger + drawer so navigation works
      // consistently everywhere.
      drawer: showBackButton ? null : AppNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(title),
        centerTitle: true,
        actions: actions,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
      ),
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(overlayOpacity)),
          SafeArea(child: body),
        ],
      ),
    );
  }
}

/// Scaffold used by the plain light-background "list" screens
/// (Destinations / Events) and detail screens (Place Details) that
/// match the prototype's white/off-white look with a big bold title
/// instead of a colored AppBar.
class ListScaffold extends StatelessWidget {
  const ListScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = false,
  });

  final String title;
  final Widget body;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.listBackgroundColor,
      // Same rule as AppScaffold: only pages reached from the drawer
      // (Destinations, Events) get the drawer attached; sub-pages
      // reached by pushing (Place Details) just get a back arrow.
      drawer: showBackButton ? null : AppNavigationDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
              child: Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: context.primaryTextColor),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu, color: context.primaryTextColor),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.primaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(child: body),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: NeedHelpLink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The small "? Need help?" link shown at the bottom of several
/// prototype screens.
class NeedHelpLink extends StatelessWidget {
  const NeedHelpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.help_outline, size: 16, color: Colors.brown[800]),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpSupportPage()),
            );
          },
          child: Text(
            tr('need_help'),
            style: TextStyle(
              color: Colors.blue[900],
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

/// A translucent card placed on top of the background image (About
/// Oman intro text, notification entries, etc). Adapts between a
/// light and dark translucent panel based on the current theme.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: context.cardSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.secondaryTextColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single grid "place" card matching the Destinations / Events
/// screens: star badge, image placeholder, name, location line,
/// short description, and a red "Explore More" button.
class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.name,
    required this.location,
    required this.description,
    required this.icon,
    this.imageAsset,
    this.imageUrl,
    this.starred = true,
    required this.onExplore,
  });

  final String name;
  final String location;
  final String description;
  final IconData icon;

  /// Optional path to a local asset image (e.g.
  /// 'assets/destinations/nizwa_fort.jpg'). When null, falls back
  /// to a colored icon tile. Ignored when [imageUrl] is set.
  final String? imageAsset;

  /// Optional photo URL (used for admin-added destinations/events,
  /// which can't ship a bundled asset file). Takes priority over
  /// [imageAsset] when both are provided.
  final String? imageUrl;
  final bool starred;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(),
                if (starred)
                  const Positioned(
                    top: 6,
                    left: 6,
                    child: Icon(Icons.star, color: AppColors.starGold, size: 20),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: context.primaryTextColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.pinMaroon),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.pinMaroon),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.2,
                color: context.secondaryTextColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: onExplore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.explorRed,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(tr('e_explore_more'), style: const TextStyle(fontSize: 11)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholderTile(loading: true);
        },
        errorBuilder: (context, error, stackTrace) => _placeholderTile(),
      );
    }
    if (imageAsset != null) {
      return Image.asset(
        imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderTile(),
      );
    }
    return _placeholderTile();
  }

  Widget _placeholderTile({bool loading = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown[300]!, Colors.brown[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: loading
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
            )
          : Icon(icon, color: Colors.white70, size: 36),
    );
  }
}