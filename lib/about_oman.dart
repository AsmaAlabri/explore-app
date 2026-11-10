import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'l10n/app_strings.dart';
import 'widgets/app_scaffold.dart';

class AboutOmanPage extends StatelessWidget {
  const AboutOmanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return AppScaffold(
          title: tr('about_oman'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  tr('welcome_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: Text(
                    tr('about_oman_intro'),
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: context.primaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NeedHelpLink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
