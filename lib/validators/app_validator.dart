// lib/validators/app_validator.dart
// NOTE: login_screen and registration_screen import this as:
//   '../validators/app_validator.dart'
// and use the class name "Validators"

class Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    if (!value.contains(RegExp(r'[A-Z]')))
      return 'Need at least 1 uppercase letter';
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
      return 'Need at least 1 special character';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please re-type your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }
}
