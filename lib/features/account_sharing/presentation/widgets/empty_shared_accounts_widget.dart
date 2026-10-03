import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmptySharedAccountsWidget extends StatelessWidget {
  const EmptySharedAccountsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'no_accounts_to_show'.tr(),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
