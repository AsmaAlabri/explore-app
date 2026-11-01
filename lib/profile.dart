import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'avatars.dart';
import 'edit_profile.dart';
import 'firebase_error.dart';
import 'l10n/app_strings.dart';
import 'reset_password.dart';
import 'user_roles.dart';
import 'welcome.dart';
import 'widgets/app_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isProfileLoading = true;
  String _name = "";
  String _email = "";
  String _role = defaultUserRole;
  String _avatarId = kDefaultAvatarId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isProfileLoading = false;
      });
      return;
    }

    try {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {}

    if (user == null) {
      setState(() {
        _isProfileLoading = false;
      });
      return;
    }

    var name = user.displayName ?? "";
    final email = user.email ?? "";
    var role = defaultUserRole;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('users/${user.uid}')
          .get();
      final value = snapshot.value;

      if (value is Map) {
        final savedName = value['name']?.toString();
        final savedEmail = value['email']?.toString();
        final savedRole = value['role']?.toString();
        final savedAvatar = value['avatarId']?.toString();

        if (savedName != null && savedName.isNotEmpty) {
          name = savedName;
        }

        if (savedRole != null && savedRole.isNotEmpty) {
          role = savedRole;
        }

        if (savedAvatar != null && savedAvatar.isNotEmpty) {
          _avatarId = savedAvatar;
        }

        if (savedEmail != email) {
          FirebaseDatabase.instance
              .ref('users/${user.uid}')
              .update({'email': email});
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _name = name;
        _email = email;
        _role = role;
        _isProfileLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _name = name;
        _email = email;
        _role = role;
        _isProfileLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firebaseErrorMessage(error)),
        ),
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomePage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppSettings is the app's real theme/language controller
    // (lib/app_settings.dart). Listening to it here is what makes the
    // Theme and Language toggles below actually take effect, on this
    // page and the rest of the app.
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return ListScaffold(
          title: tr('profile_settings'),
          showBackButton: true,
          body: _isProfileLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      // Gradient header band with avatar, name, email, role.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.brown[700]!, Colors.brown[900]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 3),
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: avatarById(_avatarId).color,
                                child: Icon(
                                  avatarById(_avatarId).icon,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _name.isEmpty ? tr('e_user') : _name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.brown[50],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                roleLabelTr(_role),
                                style: TextStyle(
                                  color: Colors.brown[900],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 18,
                        ),
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                tr('account'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            _SettingsTile(
                              icon: Icons.key,
                              label: tr('change_password'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ResetPasswordPage(),
                                  ),
                                );
                              },
                            ),

                            _SettingsTile(
                              icon: Icons.edit,
                              label: tr('edit_profile'),
                              onTap: () async {
                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                );

                                if (updated == true) {
                                  setState(() => _isProfileLoading = true);
                                  _loadProfile();
                                }
                              },
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                tr('theme'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.primaryTextColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Reads/writes AppSettings.instance directly, so
                            // this actually switches the whole app's theme.
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _SegmentedToggle(
                                leftIcon: Icons.light_mode,
                                leftLabel: tr('light_mode'),
                                rightIcon: Icons.dark_mode,
                                rightLabel: tr('dark_mode'),
                                leftSelected: !AppSettings.instance.isDarkMode,
                                onLeftTap: () => AppSettings.instance
                                    .setThemeMode(ThemeMode.light),
                                onRightTap: () => AppSettings.instance
                                    .setThemeMode(ThemeMode.dark),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                tr('language'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.primaryTextColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Reads/writes AppSettings.instance directly, so
                            // this actually switches the whole app's
                            // language (and right-to-left layout).
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _SegmentedToggle(
                                leftLabel: 'ENG',
                                rightLabel: 'عربي',
                                leftSelected: !AppSettings.instance.isArabic,
                                onLeftTap: () => AppSettings.instance
                                    .setLocale(const Locale('en')),
                                onRightTap: () => AppSettings.instance
                                    .setLocale(const Locale('ar')),
                              ),
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red[600]!,
                                      Colors.brown[900]!,
                                    ],
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: logout,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.logout,
                                              color: Colors.white),
                                          const SizedBox(width: 10),
                                          Text(
                                            tr('logout'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

/// A single row inside the Account card, with a small circular icon
/// badge instead of a bare icon, for a more finished look.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.brown[800], size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.primaryTextColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: context.mutedTextColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// A two-option animated pill toggle (used for Theme and Language).
class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    this.leftIcon,
    required this.leftLabel,
    this.rightIcon,
    required this.rightLabel,
    required this.leftSelected,
    required this.onLeftTap,
    required this.onRightTap,
  });

  final IconData? leftIcon;
  final String leftLabel;
  final IconData? rightIcon;
  final String rightLabel;
  final bool leftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.brown[200]!, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              icon: leftIcon,
              label: leftLabel,
              selected: leftSelected,
              onTap: onLeftTap,
            ),
          ),
          Expanded(
            child: _SegmentButton(
              icon: rightIcon,
              label: rightLabel,
              selected: !leftSelected,
              onTap: onRightTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.brown[800];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.brown[800] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}