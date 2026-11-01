import 'l10n/app_strings.dart';

const userRoles = <String, String>{
  'admin': 'Admin',
  'business_owner': 'Local Business Owner',
  'tourist': 'Tourist',
};

/// Roles a new user can pick for themselves during registration.
/// Admin accounts are provisioned separately, never self-registered.
const registrableUserRoles = <String, String>{
  'tourist': 'Tourist',
  'business_owner': 'Local Business Owner',
};

const defaultUserRole = 'tourist';

/// English-only label — kept for places that don't need translation
/// (e.g. writing the role to Firebase).
String roleLabel(String role) {
  return userRoles[role] ?? userRoles[defaultUserRole]!;
}

/// Translated label for the current app language — use this in any
/// UI text (dropdowns, error messages) so it follows the language
/// switch.
String roleLabelTr(String role) {
  switch (role) {
    case 'admin':
      return tr('role_admin');
    case 'business_owner':
      return tr('role_business_owner');
    case 'tourist':
      return tr('role_tourist');
    default:
      return tr('role_tourist');
  }
}