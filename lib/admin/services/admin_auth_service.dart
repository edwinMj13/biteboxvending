import 'package:firebase_auth/firebase_auth.dart';
import '../admin_config.dart';

class AdminAuthException implements Exception {
  final String message;
  const AdminAuthException(this.message);

  @override
  String toString() => message;
}

/// Admin login by mobile number + OTP.
///
/// To switch to real SMS OTP later, only this class needs to change:
/// [sendOtp] → `FirebaseAuth.instance.signInWithPhoneNumber(phone)`,
/// [verifyOtp] → `confirmationResult.confirm(otp)`.
class AdminAuthService {
  final _auth = FirebaseAuth.instance;

  /// "96568 61728" / "+91 96568-61728" → "+919656861728".
  String normalizePhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91$digits';
    return '+$digits';
  }

  Future<void> sendOtp(String phone) async {
    if (!AdminConfig.allowedPhones.contains(normalizePhone(phone))) {
      throw const AdminAuthException(
        'This mobile number is not registered as an admin.',
      );
    }
    // Dummy mode: nothing is sent.
  }

  Future<void> verifyOtp(String phone, String otp) async {
    if (!AdminConfig.allowedPhones.contains(normalizePhone(phone))) {
      throw const AdminAuthException(
        'This mobile number is not registered as an admin.',
      );
    }
    if (otp.trim() != AdminConfig.dummyOtp) {
      throw const AdminAuthException('Incorrect OTP. Please try again.');
    }
    await _signInToFirebase();
  }

  /// Signs in to the shared admin account, creating it on first use.
  Future<void> _signInToFirebase() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: AdminConfig.firebaseEmail,
        password: AdminConfig.firebasePassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found' && e.code != 'invalid-credential') {
        throw AdminAuthException(e.message ?? 'Login failed (${e.code})');
      }
      try {
        await _auth.createUserWithEmailAndPassword(
          email: AdminConfig.firebaseEmail,
          password: AdminConfig.firebasePassword,
        );
      } on FirebaseAuthException catch (e) {
        throw AdminAuthException(
          e.code == 'email-already-in-use'
              ? 'Admin account password does not match AdminConfig.'
              : e.code == 'operation-not-allowed'
                  ? 'Enable Email/Password sign-in in the Firebase console.'
                  : (e.message ?? 'Login failed (${e.code})'),
        );
      }
    }
  }
}
