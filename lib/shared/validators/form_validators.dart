import 'package:flutter/services.dart';

/// Validators and input formatters shared by the public website forms.
///
/// Every validator trims the value first, so "   " counts as empty.
class FormValidators {
  FormValidators._();

  static const int nameMax = 60;
  static const int emailMax = 254;
  static const int phoneMax = 16; // "+91 98765 43210" plus a little slack
  static const int locationMax = 100;
  static const int subjectMax = 100;
  static const int messageMax = 1000;

  static final RegExp _name = RegExp(r"^[A-Za-z][A-Za-z .'-]*$");
  static final RegExp _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\.[A-Za-z]{2,}$",
  );
  static final RegExp _hasLetter = RegExp(r'[A-Za-z]');

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your name';
    if (v.length < 2) return 'Name is too short';
    if (v.length > nameMax) return 'Name must be under $nameMax characters';
    if (!_name.hasMatch(v)) {
      return 'Use letters only (spaces, . \' - allowed)';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email';
    if (v.length > emailMax) return 'Email address is too long';
    if (v.contains('..') || !_email.hasMatch(v)) {
      return 'Enter a valid email, e.g. name@example.com';
    }
    return null;
  }

  /// Indian mobile number: 10 digits starting with 6-9. An optional +91,
  /// 91 or leading 0 is accepted, as are spaces and dashes.
  static String? indianMobile(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^\+?[0-9 -]+$').hasMatch(v)) {
      return 'Use digits only';
    }
    final digits = normalizeIndianMobile(v);
    if (digits.length != 10) return 'Enter a 10-digit mobile number';
    if (!RegExp(r'^[6-9]').hasMatch(digits)) {
      return 'Mobile numbers start with 6, 7, 8 or 9';
    }
    return null;
  }

  /// Strips formatting and the +91 / 0 prefix, leaving the 10-digit number.
  static String normalizeIndianMobile(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  /// "098765-43210" → "+91 98765 43210".
  static String formatIndianMobile(String value) {
    final d = normalizeIndianMobile(value);
    return d.length == 10
        ? '+91 ${d.substring(0, 5)} ${d.substring(5)}'
        : value.trim();
  }

  /// Required free text with a minimum length that must contain letters.
  static String? Function(String?) text({
    required String emptyMessage,
    required String fieldName,
    int min = 2,
    required int max,
  }) {
    return (value) {
      final v = value?.trim() ?? '';
      if (v.isEmpty) return emptyMessage;
      if (v.length < min) return '$fieldName must be at least $min characters';
      if (v.length > max) return '$fieldName must be under $max characters';
      if (!_hasLetter.hasMatch(v)) {
        return 'Please enter a valid ${fieldName.toLowerCase()}';
      }
      return null;
    };
  }

  /// Optional free text: only the maximum length is checked.
  static String? Function(String?) optionalText({
    required String fieldName,
    required int max,
  }) {
    return (value) {
      final v = value?.trim() ?? '';
      if (v.length > max) return '$fieldName must be under $max characters';
      return null;
    };
  }

  // ---- Input formatters: block characters that can never be valid. ----

  static final List<TextInputFormatter> nameFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z .'-]")),
    LengthLimitingTextInputFormatter(nameMax),
  ];

  static final List<TextInputFormatter> emailFormatters = [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LengthLimitingTextInputFormatter(emailMax),
  ];

  static final List<TextInputFormatter> phoneFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ -]')),
    LengthLimitingTextInputFormatter(phoneMax),
  ];
}
