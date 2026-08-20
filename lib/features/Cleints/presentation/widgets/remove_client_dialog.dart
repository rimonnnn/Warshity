import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/spacing_widgets.dart';
import 'package:warshity/features/Cleints/presentation/cubit/remove_clients_cubit.dart';
import 'package:warshity/features/Cleints/presentation/cubit/remove_clients_state.dart';

class RemoveClientDialog extends StatelessWidget {
  final String clientId;
  final String clientName;

  const RemoveClientDialog({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RemoveClientCubit, RemoveClientState>(
      listenWhen: (previous, current) {
        if (previous is RemoveClientAction && current is RemoveClientAction) {
          return previous.status != current.status;
        }

        return current is RemoveClientAction;
      },
      listener: (context, state) {
        if (state is! RemoveClientAction) return;

        switch (state.status) {
          case RemoveClientStatus.initial:
            break;

          case RemoveClientStatus.loading:
            break;

          case RemoveClientStatus.success:
            context.pop();
            break;

          case RemoveClientStatus.failure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'something_error'.tr()),
              ),
            );
            break;
        }
      },
      buildWhen: (previous, current) {
        if (previous is RemoveClientAction && current is RemoveClientAction) {
          return previous.status != current.status;
        }

        return current is RemoveClientAction;
      },
      builder: (context, state) {
        final isLoading =
            state is RemoveClientAction &&
            state.status == RemoveClientStatus.loading;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          backgroundColor: context.colors.surface,
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: context.colors.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: context.colors.error,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'remove_client'.tr(),
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                HeightSpace(16.h),

                Text(
                  'remove_client_confirmation'.tr(
                    namedArgs: {'name': clientName},
                  ),
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                HeightSpace(24.h),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryButtonWidget(
                        iconData: Icons.close,
                        iconSize: 18.sp,
                        textColor: context.colors.primary,
                        iconeColor: context.colors.primary,
                        fontSize: 16.sp,
                        buttonColor: context.colors.surfaceContainerHighest,
                        buttonText: 'cancel'.tr(),
                        borderRadius: AppRadius.sm,
                        onPress: isLoading ? null : () => context.pop(),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: PrimaryButtonWidget(
                        iconData: Icons.delete_outline,
                        iconSize: 18.sp,
                        iconeColor: context.colors.onError,
                        fontSize: 16.sp,
                        buttonColor: context.colors.error,
                        buttonText: isLoading ? ''.tr() : 'remove'.tr(),
                        borderRadius: AppRadius.sm,
                        onPress: isLoading
                            ? null
                            : () {
                                context.read<RemoveClientCubit>().removeClient(
                                  clientId: clientId,
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
