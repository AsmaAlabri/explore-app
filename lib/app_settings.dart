import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for the app's language and theme.
///
/// This is a plain [ChangeNotifier] (no extra state-management package
/// needed) that main.dart listens to with a ListenableBuilder, so
/// changing the locale or theme here rebuilds the whole app instantly.
/// Choices are saved with shared_preferences so they survive app restarts.
class AppSettings extends ChangeNotifier {
  AppSettings._internal();
  static final AppSettings instance = AppSettings._internal();

  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme_mode';

  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Call once at startup (before runApp) to restore the saved choices.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    final savedTheme = prefs.getString(_themeKey);

    if (savedLocale == 'ar') {
      _locale = const Locale('ar');
    } else if (savedLocale == 'en') {
      _locale = const Locale('en');
    }

    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> toggleLanguage() {
    return setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> toggleTheme() {
    return setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }
}