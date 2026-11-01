import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'l10n/app_strings.dart';
import 'widgets/app_drawer.dart';
import 'widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild this page whenever the language or theme changes, so
    // its text and colors stay in sync even though it isn't the page
    // where the toggle lives (that's Profile & Settings).
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return Scaffold(
          drawer: AppNavigationDrawer(),
          appBar: null,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/bg.jpg',
                fit: BoxFit.cover,
              ),

              Container(
                color: Colors.black.withOpacity(0.35),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          tr('welcome_title'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Text(
                          tr('home_intro'),
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: context.primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}