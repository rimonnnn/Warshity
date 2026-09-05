import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension InvoicePdfLabels on BuildContext {
  Map<String, String> get invoiceLabels => {
    'masiter': 'masiter'.tr(),
    'invoice_no': 'invoice_no'.tr(),
    'customer': 'customer'.tr(),
    'item': 'item'.tr(),
    'qty': 'qty'.tr(),
    'price': 'the_price'.tr(),
    'total': 'total'.tr(),
    'subtotal': 'subtotal'.tr(),
    'discount': 'discount'.tr(),
    'paid': 'paid'.tr(),
    'remaining': 'remaining'.tr(),
    'thank_you': 'thank_you'.tr(),
  };
}
