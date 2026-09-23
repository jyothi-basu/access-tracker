/// Shared validation utilities for authentication forms.
class AuthValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required.';
    if (value.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain an uppercase letter.';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must contain a lowercase letter.';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain a digit.';
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value != password) return 'Passwords do not match.';
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.length != 6 || int.tryParse(value) == null) {
      return 'Enter a valid 6-digit OTP.';
    }
    return null;
  }
}
