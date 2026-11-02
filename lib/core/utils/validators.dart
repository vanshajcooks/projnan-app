class Validators {
  Validators._();

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 100) {
      return 'Full name must be between 2 and 100 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final normalized = value.trim().toLowerCase();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(normalized)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    final normalized = value.trim().toLowerCase().replaceAll(RegExp(r'^@'), '');
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]{3,30}$');
    if (!usernameRegex.hasMatch(normalized)) {
      return 'Username must be 3-30 characters (letters, numbers, _, -)';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must include at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must include at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must include at least one number';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>\_\-+=\[\]\\\/~`' r"']").hasMatch(value)) {
      return 'Must include at least one special character';
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  static String? validateClassCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final trimmed = value.trim();
    if (trimmed.length < 4 || trimmed.length > 12) {
      return 'Class code is usually 4-12 characters';
    }
    return null;
  }
}
