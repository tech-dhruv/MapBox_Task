// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Validator {
  // Validations
  static const EMAIL_VALIDATOR =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static const PASS_VALIDATOR =
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*?[0-9])(?=.*?[!@#\\\$&*~]).{6,}';
  static const PHONE_VALIDATOR = r'(^(?:[+0]9)?[0-9]{10,12}$)';

  static String? notValidCheck(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter valid value";
    }
    return null;
  }
  
  static String? notValidAddress(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter valid address";
    }
    return null;
  }

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter name";
    }
    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your phone number";
    }

    if (!RegExp(PHONE_VALIDATOR).hasMatch(value) && kReleaseMode) {
      return "Please enter valid phone number";
    }

    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your mail";
    }
    if (!RegExp(EMAIL_VALIDATOR).hasMatch(value) && !kReleaseMode) {
      return "Please enter valid email";
    }
    return null;
  }

  static String? lPassValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }

    if (value.length < 6) {
      return "Please enter valid password";
    }
    return null;
  }

  static String? passValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }

    if (!RegExp(PASS_VALIDATOR).hasMatch(value) && kReleaseMode) {
      return "Password is not valid (should contain at least one upper case, one lower case, one digit, one Special character and at least 6 characters in length)";
    }

    return null;
  }

  static String? confirmPassValidator(
      String? value, TextEditingController _passController) {
    if (value == null || value.isEmpty) {
      return "Please enter your confirm password";
    }

    if (_passController.text != value) {
      return "Both password must be same";
    }

    return null;
  }
}
