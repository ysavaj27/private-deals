class AppValidator {
  static String? password(String? value, [String? pass]) {
    if (value == null || value.isEmpty) {
      return 'Enter password';
    }
    // Check for at least 8 characters
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    // Check for at least one upper case letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one upper case letter.';
    }

    // Check for at least one lower case letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lower case letter.';
    }

    // Check for at least one numeric character
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one numeric character.';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*()_+{}|:"<>?~-]'))) {
      return 'Password must contain at least one special character.';
    }
    if (pass != null && value.trim() != pass) {
      return 'Confirm password not matching';
    }
    return null;
  }
}
