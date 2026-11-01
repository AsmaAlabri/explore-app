import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'avatars.dart';
import 'firebase_error.dart';
import 'l10n/app_strings.dart';
import 'widgets/app_scaffold.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedAvatarId = kDefaultAvatarId;
  String _originalEmail = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {}

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    var name = user.displayName ?? '';
    final email = user.email ?? '';
    var avatarId = kDefaultAvatarId;

    try {
      final snapshot =
          await FirebaseDatabase.instance.ref('users/${user.uid}').get();
      final value = snapshot.value;

      if (value is Map) {
        final savedName = value['name']?.toString();
        final savedEmail = value['email']?.toString();
        final savedAvatar = value['avatarId']?.toString();

        if (savedName != null && savedName.isNotEmpty) {
          name = savedName;
        }
        if (savedAvatar != null && savedAvatar.isNotEmpty) {
          avatarId = savedAvatar;
        }

        if (savedEmail != email) {
          FirebaseDatabase.instance
              .ref('users/${user.uid}')
              .update({'email': email});
        }
      }
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _nameController.text = name;
      _emailController.text = email;
      _originalEmail = email;
      _selectedAvatarId = avatarId;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final emailChanged = newEmail != _originalEmail;

    try {
      await _performSave(user, newName, newEmail, emailChanged);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final reauthed = await _reauthenticate(user);

        if (reauthed) {
          try {
            await _performSave(user, newName, newEmail, emailChanged);
          } on FirebaseAuthException catch (e2) {
            if (!mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(firebaseErrorMessage(e2))));
          } catch (e2) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr('e_could_not_update_profile').replaceAll('{error}', e2.toString()))),
            );
          }
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(firebaseErrorMessage(e))));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('e_could_not_update_profile').replaceAll('{error}', e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _performSave(
    User user,
    String newName,
    String newEmail,
    bool emailChanged,
  ) async {
    await user.updateDisplayName(newName);

    await FirebaseDatabase.instance.ref('users/${user.uid}').update({
      'name': newName,
      'avatarId': _selectedAvatarId,
      if (!emailChanged) 'email': newEmail,
    });

    String message = tr('e_profile_updated');

    if (emailChanged) {
      await user.verifyBeforeUpdateEmail(newEmail);
      message =
          tr('e_profile_updated_check_email').replaceAll('{email}', newEmail);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context, true);
  }

  Future<bool> _reauthenticate(User user) async {
    final passwordController = TextEditingController();
    bool isVerifying = false;
    String? errorText;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(tr('e_confirm_your_password')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('e_reauth_explanation'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: tr('e_current_password'),
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: Text(tr('e_cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isVerifying
                      ? null
                      : () async {
                          if (passwordController.text.isEmpty) {
                            setDialogState(
                              () => errorText = tr('e_enter_your_password'),
                            );
                            return;
                          }

                          setDialogState(() {
                            isVerifying = true;
                            errorText = null;
                          });

                          try {
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: passwordController.text,
                            );
                            await user.reauthenticateWithCredential(credential);

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                          } on FirebaseAuthException catch (e) {
                            setDialogState(() {
                              isVerifying = false;
                              errorText = e.code == 'wrong-password' ||
                                      e.code == 'invalid-credential'
                                  ? tr('e_incorrect_password')
                                  : firebaseErrorMessage(e);
                            });
                          }
                        },
                  child: isVerifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(tr('e_confirm')),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Same as Profile & Settings: listening to AppSettings.instance
    // makes this page's text switch language live too.
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return ListScaffold(
          title: tr('edit_profile'),
          showBackButton: true,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.brown[800]!, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: avatarById(_selectedAvatarId).color,
                            child: Icon(
                              avatarById(_selectedAvatarId).icon,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          margin: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                tr('e_choose_avatar'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                alignment: WrapAlignment.center,
                                children: kAvatars.map((avatar) {
                                  final isSelected =
                                      avatar.id == _selectedAvatarId;
                                  return GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedAvatarId = avatar.id,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.brown[800]!
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 26,
                                        backgroundColor: avatar.color,
                                        child: Icon(
                                          avatar.icon,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          margin: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                tr('e_your_details'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: tr('full_name_hint'),
                                  prefixIcon: const Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.brown[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.brown[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.brown[800]!, width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return tr('err_enter_name');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: tr('email_hint'),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.brown[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.brown[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.brown[800]!, width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return tr('err_enter_email');
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return tr('err_enter_valid_email');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                tr('e_change_email_note'),
                                style:
                                    const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    tr('e_save_changes'),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}