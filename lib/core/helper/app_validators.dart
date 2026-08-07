import 'package:easy_localization/easy_localization.dart';

class AppValidators {
  static String? shopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validator_shop_name_required'.tr();
    }
    return null;
  }

  static String? accountName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validator_account_name_required'.tr();
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'validator_email_required'.tr();
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'validator_password_required'.tr();
    }

    if (value.length < 8) {
      return 'validator_password_length'.tr();
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'validator_confirm_password_required'.tr();
    }

    if (value != password) {
      return 'validator_password_not_match'.tr();
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
      return 'validator_terms_required'.tr();
    }
    return null;
  }

  static String? clientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validator_client_name_required'.tr();
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validator_phone_required'.tr();
    }

    final phoneRegex = RegExp(r'^01[0125][0-9]{8}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'validator_phone_invalid'.tr();
    }

    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validator_price_required'.tr();
    }

    final price = double.tryParse(value.trim());

    if (price == null) {
      return 'validator_price_invalid'.tr();
    }

    if (price <= 0) {
      return 'validator_price_greater_than_zero'.tr();
    }

    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validator_address_required'.tr();
    }

    if (value.trim().length < 5) {
      return 'validator_address_too_short'.tr();
    }

    return null;
  }
}
