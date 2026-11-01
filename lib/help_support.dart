import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';
import 'l10n/app_strings.dart';
import 'widgets/app_scaffold.dart';

/// The page every "Need help?" link in the app leads to (drawer,
/// NeedHelpLink, Profile & Settings). A short FAQ plus a
/// tap-to-copy contact email — no backend needed.
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _faqCount = 5;

  void _copyEmail(BuildContext context) {
    Clipboard.setData(ClipboardData(text: tr('contact_email_value')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('copied_to_clipboard'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return AppScaffold(
          title: tr('help_support'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  tr('help_support_intro'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        for (var i = 1; i <= _faqCount; i++)
                          ExpansionTile(
                            title: Text(
                              tr('faq_q$i'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: context.primaryTextColor,
                              ),
                            ),
                            iconColor: context.primaryTextColor,
                            collapsedIconColor: context.secondaryTextColor,
                            childrenPadding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('faq_a$i'),
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: context.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tr('contact_us'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  child: InkWell(
                    onTap: () => _copyEmail(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: context.primaryTextColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tr('contact_email_value'),
                            style: TextStyle(color: context.primaryTextColor),
                          ),
                        ),
                        Icon(
                          Icons.copy,
                          size: 18,
                          color: context.secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}