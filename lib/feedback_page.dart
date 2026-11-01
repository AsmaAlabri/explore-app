import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';
import 'widgets/app_scaffold.dart';

/// Feedback form: 5-star rating, free text, a few quick checkboxes,
/// and a submit button, laid out on a translucent card so it reads
/// clearly over the background photo in both light and dark mode.
/// Submitting writes the feedback to Firebase Realtime Database
/// under feedback/{auto-id}.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key, this.placeName});

  /// Optional — set when reached from a specific Place Details page,
  /// so the feedback can be tied to that place.
  final String? placeName;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 0;
  final _textController = TextEditingController();
  bool _submitting = false;

  // Keys map to translated labels via tr('tag_...') below; the keys
  // themselves ('Easy to use', etc.) are what gets written to
  // Firebase, so they stay in English regardless of app language.
  final Map<String, bool> _tags = {
    'Easy to use': true,
    'Helpful information': true,
    'Needs Improvement': false,
  };

  String _tagLabel(String key) {
    switch (key) {
      case 'Easy to use':
        return tr('tag_easy_to_use');
      case 'Helpful information':
        return tr('tag_helpful_info');
      case 'Needs Improvement':
        return tr('tag_needs_improvement');
      default:
        return key;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('select_rating_first'))),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final ref = FirebaseDatabase.instance.ref('feedback').push();
      await ref.set({
        'place': widget.placeName ?? 'General',
        'rating': _rating,
        'comment': _textController.text.trim(),
        'tags': _tags.entries.where((e) => e.value).map((e) => e.key).toList(),
        'userId': uid,
        'timestamp': ServerValue.timestamp,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('feedback_thanks'))),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('feedback_submit_error_prefix')}$e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: tr('feedback'),
      showBackButton: true,
      overlayOpacity: 0.72,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.placeName != null
                        ? widget.placeName!
                        : tr('feedback_prompt'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.placeName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      tr('feedback_prompt'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        iconSize: 40,
                        splashRadius: 28,
                        onPressed: () => setState(() => _rating = starIndex),
                        icon: Icon(
                          starIndex <= _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.starGold,
                        ),
                      );
                    }),
                  ),

                  if (_rating > 0)
                    Text(
                      tr('rating_value_label')
                          .replaceAll('{n}', _rating.toString()),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.secondaryTextColor,
                        fontSize: 12.5,
                      ),
                    ),

                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.brown.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brown.withOpacity(0.35),
                      ),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: 4,
                      style: TextStyle(color: context.primaryTextColor),
                      decoration: InputDecoration(
                        hintText: tr('feedback_hint'),
                        hintStyle: TextStyle(color: context.mutedTextColor),
                        contentPadding: const EdgeInsets.all(14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ..._tags.keys.map(
                    (key) => CheckboxListTile(
                      value: _tags[key],
                      onChanged: (value) =>
                          setState(() => _tags[key] = value ?? false),
                      title: Text(
                        _tagLabel(key),
                        style: TextStyle(
                          color: context.primaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.brown[700],
                      checkColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.explorRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              tr('submit_feedback'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}