import 'l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

String firebaseErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return tr('a_err_email_registered');
      case 'invalid-email':
        return tr('a_err_valid_email');
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return tr('a_err_invalid_credentials');
      case 'weak-password':
        return tr('a_err_stronger_password');
      case 'user-disabled':
        return tr('a_err_account_disabled');
      case 'network-request-failed':
        return tr('a_err_network');
      case 'too-many-requests':
        return tr('a_err_too_many');
      case 'requires-recent-login':
        return tr('a_err_recent_login');
      case 'operation-not-allowed':
        return tr('a_err_op_not_allowed');
      case 'unauthorized-domain':
        return tr('a_err_unauth_domain');
      case 'configuration-not-found':
        return tr('a_err_config_not_found');
      case 'role-mismatch':
        return error.message ?? tr('a_err_role_mismatch');
      default:
        return error.message ?? tr('a_err_auth_failed');
    }
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return tr('a_err_permission');
      case 'network-request-failed':
        return tr('a_err_network');
      default:
        return error.message ?? tr('a_err_request_failed');
    }
  }

  return tr('a_err_generic');
}