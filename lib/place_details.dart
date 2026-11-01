import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'feedback_page.dart';
import 'l10n/app_strings.dart';
import 'nearby_actions.dart';
import 'view_tracker.dart';
import 'widgets/app_scaffold.dart';

/// Detail page shown after tapping "Explore More" on a Destination
/// or Event card. Matches prototype screens 7 (destination) and 11
/// (event, with Date / Timing / Things To Do bullets instead of a
/// plain paragraph).
class PlaceDetailsPage extends StatelessWidget {
  const PlaceDetailsPage({
    super.key,
    required this.name,
    required this.icon,
    this.description,
    this.infoLines,
    this.imageAsset,
    this.imageUrl,
    this.location,
    this.trackType,
    this.trackId,
    this.trackName,
  }) : assert(description != null || infoLines != null,
            'Provide either description or infoLines');

  final String name;
  final IconData icon;

  /// Plain paragraph description (used for destinations).
  final String? description;

  /// Bulleted info lines, e.g. "Date: ...", "Timing: ..." (used for
  /// events).
  final List<String>? infoLines;

  /// Optional local asset photo. Ignored when [imageUrl] is set.
  final String? imageAsset;

  /// Optional photo URL (used for admin-added destinations/events).
  /// Takes priority over [imageAsset] when both are provided. Falls
  /// back to the brown gradient + icon tile when neither is set.
  final String? imageUrl;

  /// City/region (e.g. "Nizwa" or "Muscat"), used together with the
  /// name to build an accurate Google Maps search query.
  final String? location;

  /// Optional: when set, opening this page counts as one view in the
  /// Analytics (type is 'destination', 'event' or 'business').
  final String? trackType;
  final String? trackId;
  final String? trackName;

  Future<void> _openMap(BuildContext context) async {
    final query = Uri.encodeComponent(
      location != null ? '$name, $location, Oman' : '$name, Oman',
    );
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('could_not_open_map'))),
      );
    }
  }

  Future<void> _share() async {
    final details = description ?? infoLines?.join('\n') ?? '';
    final locationLine = location != null && location!.isNotEmpty
        ? tr('e_share_in').replaceAll('{location}', location!)
        : '';

    final message = tr('e_share_message')
            .replaceAll('{name}', name)
            .replaceAll('{locationLine}', locationLine) +
        '\n\n$details';

    await Share.share(message);
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholderTile();
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

  @override
  Widget build(BuildContext context) {
    return ListScaffold(
      title: tr('place_details_title'),
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trackType != null && trackId != null)
              ViewTracker(
                type: trackType!,
                id: trackId!,
                name: trackName ?? name,
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildImage(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                    ),
                  ),
                ),
                Icon(Icons.grid_view_rounded, color: context.mutedTextColor),
              ],
            ),
            const SizedBox(height: 10),
            if (description != null)
              Text(
                description!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: context.primaryTextColor,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: infoLines!
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '•  $line',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: context.primaryTextColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMap(context),
                    icon: const Icon(Icons.map_outlined),
                    label: Text(tr('view_on_map')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryTextColor,
                      side: BorderSide(color: context.secondaryTextColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FeedbackPage(placeName: name),
                        ),
                      );
                    },
                    icon: const Icon(Icons.feedback_outlined),
                    label: Text(tr('give_feedback')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryTextColor,
                      side: BorderSide(color: context.secondaryTextColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NearbyActionsRow(name: name, location: location),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share_outlined),
                label: Text(tr('share')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primaryTextColor,
                  side: BorderSide(color: context.secondaryTextColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderTile() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown[300]!, Colors.brown[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icon, color: Colors.white70, size: 64),
    );
  }
}