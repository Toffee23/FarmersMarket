import 'package:farmers_marketplace/core/extensions/string.dart';

class Validator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (value.trim().isNotEmail) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.trim().length != 11) {
      return 'Phone number should be 11 in length';
    }
    return null;
  }

  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your account number';
    }
    if (value.trim().length != 11) {
      return 'Account number should be 11 in length';
    }
    return null;
  }

  static String? otpCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the correct code';
    }
    if (value.trim().length != 6) {
      return 'Incomplete code!';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    // if (value.trim().length != 11) {
    //   return 'Phone number should be 11 in length';
    // }
    return null;
  }

  static String? validatePassword1(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    String msg = 'Password must contain ;';

    if (value.trim().length < 6) msg += '\n - at least 7 characters';
    if (!value.trim().hasDigit) msg += '\n - at least one digit';
    if (!value.trim().hasLowercase) msg += '\n - at least one lowercase';
    if (!value.trim().hasUppercase) msg += '\n - at least one uppercase';
    if (!value.trim().hasSpecialCharacters) {
      msg += '\n - at least one special character';
    }
    if (msg.contains('\n')) return msg;

    return null;
  }

  static String? validatePassword2(String? value1, String value2) {
    if (value1 == null || value1.isEmpty) {
      return 'Please enter a password';
    }
    if (value1.trim() != value2.trim()) {
      return 'Password mismatch';
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a amount';
    }
    // if (value.length != 10) {
    //   return 'Phone number should be 11 in length';
    // }
    return null;
  }
}
