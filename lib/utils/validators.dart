class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email";
    }
    return null;
  }
 
  // static String? validatePassword(String? value) {
  //   if (value == null || value.trim().isEmpty) {
  //     return "Password is required";
  //   }
  //   return null;
  // }
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    final lowerEx = RegExp(r'[a-z]');
    final upperCase = RegExp(r'[A-Z]');
    final spCharacter = RegExp(r'[^a-zA-Z0-9]');
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    } else if (!lowerEx.hasMatch(value)) {
      return "Password must contain at least one lowercase letter";
    } else if (!upperCase.hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    } else if (!spCharacter.hasMatch(value)) {
      return "Password must contain at least one special character";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.trim().isEmpty) {
      return "Confirm Password is required";
    }
    if (value != password) {
      return "Passwords do not match";
    }
    return null;
  }
}
