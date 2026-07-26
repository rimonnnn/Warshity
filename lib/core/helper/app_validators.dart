class AppValidators {
  static String? shopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Shop name is required';
    }
    return null;
  }

  static String? accountName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account name is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    return null;
  }
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  static String? confirmPassword(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? dropdown(dynamic value, String message) {
    if (value == null) {
      return message;
    }
    return null;
  }

  static String? terms(bool accepted) {
    if (!accepted) {
      return 'You must accept the terms and conditions';
    }
    return null;
  }
}