/// Admin login settings.
///
/// CURRENTLY DUMMY OTP: no SMS is sent. Any number in [allowedPhones] can log
/// in with [dummyOtp]. Behind the scenes the portal signs in to one shared
/// Firebase account ([firebaseEmail]) so Firestore security rules still apply.
/// Replace with real Firebase phone auth before going live.
class AdminConfig {
  /// Mobile numbers allowed to log in (E.164 format, no spaces).
  static const allowedPhones = ['+919656861728'];

  static const dummyOtp = '4321';

  /// Shared Firebase account used after the dummy OTP check. It is created
  /// automatically on first login; then add its UID under `admins/` in
  /// Firestore (the portal shows the UID).
  static const firebaseEmail = 'admin@bitebox-admin.app';
  static const firebasePassword = 'BiteBox-Admin-2026!';
}
