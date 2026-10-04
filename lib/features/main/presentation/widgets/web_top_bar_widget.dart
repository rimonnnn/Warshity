import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/search_widget.dart';
import 'package:warshity/features/main/presentation/widgets/top_bar_button.dart';
import 'package:warshity/features/main/presentation/widgets/top_bar_icon_button.dart';

class WebTopBar extends StatelessWidget {
  const WebTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat.yMMMMEEEEd(
      context.locale.languageCode,
    ).format(DateTime.now());

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 5,
            child: CustomSearchTextField(height: 36, hintText: 'search1'.tr()),
          ),

          const SizedBox(width: 16),

          // Current date
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(
                alpha: .10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  currentDate,
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Language
          TopBarIconButton(icon: Icons.translate, onPressed: () {}),

          const SizedBox(width: 8),

          // Notifications
          Stack(
            children: [
              TopBarIconButton(
                icon: Icons.notifications_none,
                onPressed: () {},
              ),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          // Left actions
          const Spacer(),
          Row(
            children: [
              TopBarButton(
                icon: Icons.add,
                label: 'new_invoice'.tr(),
                filled: true,
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              TopBarButton(
                icon: Icons.add,
                label: 'add_product'.tr(),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
