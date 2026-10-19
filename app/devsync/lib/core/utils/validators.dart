import 'package:devsync/core/constants/app_constants.dart';
import 'package:devsync/core/constants/app_strings.dart';

class AppValidators {
  AppValidators._();

  // 1. Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterEmailReq;
    }
    final emailRegex = RegExp(AppConstants.emailRegex);
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.validEmailReq;
    }
    return null;
  }

  // 2. Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterPassReq;
    }
    if (value.length < AppConstants.passwordMinLength) {
      return AppStrings.passLengthReq;
    }
    final passwordRegex = RegExp(AppConstants.passwordRegex);
    if (!passwordRegex.hasMatch(value)) {
      return AppStrings.passRegexReq;
    }
    return null;
  }

  // 3. Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterNameReq;
    }
    if (value.trim().length < AppConstants.nameMinLength) {
      return AppStrings.nameLengthReq;
    }
    return null;
  }

  // 4. Confirm Password validation
  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPassReq;
    }
    if (value != originalPassword) {
      return AppStrings.passNotMatch;
    }
    return null;
  }

  // 5. URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; 
    }
    final urlRegex = RegExp(AppConstants.urlRegex);
    if (!urlRegex.hasMatch(value)) {
      return AppStrings.validUrlReq; 
    }
    return null;
  }

  // 6. General text/title validation
  static String? validateRequiredField(String? value, {int minLength = 3}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequiredReq;
    }
    if (value.trim().length < minLength) {
      return AppStrings.fieldLengthReq;
    }
    return null;
  }
}
