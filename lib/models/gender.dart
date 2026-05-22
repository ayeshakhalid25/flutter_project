// lib/models/gender.dart

enum Gender {
  male,
  female,
  preferNotToSay,
  other;

  // Returns a readable label for each enum value
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
      case Gender.other: // ✅ FIXED: added missing case
        return 'Other';
    }
  }
}
