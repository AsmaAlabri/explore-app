import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'admin_home.dart';
import 'app_settings.dart';
import 'firebase_options.dart';
import 'welcome.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Restore the saved language/theme choice before the app draws
  // anything, so it doesn't flash back to English/Light on launch.
  await AppSettings.instance.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.brown,

    scaffoldBackgroundColor: const Color(0xFFF5F5F5),

    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.brown,

    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),

    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // AppSettings is a ChangeNotifier — this rebuilds the whole app
    // any time toggleTheme()/toggleLanguage()/setLocale()/
    // setThemeMode() is called anywhere (e.g. from Profile & Settings).
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final isArabic = AppSettings.instance.isArabic;

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'Explore Oman',

          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: AppSettings.instance.themeMode,

          // Arabic reads right-to-left; this flips the whole layout
          // automatically whenever the language changes.
          builder: (context, child) {
            return Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },

          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return _SignedInGate(uid: user.uid);
        }

        return const WelcomePage();
      },
    );
  }
}

/// Decides where a signed-in person lands: admins open the admin
/// dashboard, everyone else opens the normal Home page. The role is
/// read once from users/<uid>/role in the database.
class _SignedInGate extends StatefulWidget {
  const _SignedInGate({required this.uid});

  final String uid;

  @override
  State<_SignedInGate> createState() => _SignedInGateState();
}

class _SignedInGateState extends State<_SignedInGate> {
  late Future<bool> _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = _checkAdmin();
  }

  @override
  void didUpdateWidget(covariant _SignedInGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _isAdmin = _checkAdmin();
    }
  }

  Future<bool> _checkAdmin() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('users/${widget.uid}/role')
          .get();
      return snapshot.value?.toString() == 'admin';
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdmin,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return snapshot.data == true
            ? const AdminHomePage()
            : const HomePage();
      },
    );
  }
}