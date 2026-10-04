import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/clients/presentation/cubit/remove_clients_state.dart';
import 'package:warshity/features/clients/presentation/cubit/remove_clients_cubit.dart';

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
                content: Text(
                  state.errorMessage ?? 'something_error'.tr(),
                ),
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
        final bool isLoading =
            state is RemoveClientAction &&
            state.status == RemoveClientStatus.loading;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = MediaQuery.sizeOf(context).width;
            final double screenHeight = MediaQuery.sizeOf(context).height;

            final bool isMobile = screenWidth < 600;
            final bool isSmallMobile = screenWidth < 380;

            final double dialogWidth = isMobile
                ? (screenWidth - 32).clamp(280.0, 500.0)
                : 500.0;

            final double horizontalPadding = isSmallMobile ? 16 : 22;
            final double verticalPadding = isSmallMobile ? 16 : 20;

            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 20 : 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              backgroundColor: context.colors.surface,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 280,
                  maxWidth: dialogWidth,
                  maxHeight: screenHeight - (isMobile ? 40 : 80),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: isMobile ? 44 : 48,
                            height: isMobile ? 44 : 48,
                            decoration: BoxDecoration(
                              color: context.colors.errorContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: context.colors.error,
                              size: isMobile ? 22 : 24,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'remove_client'.tr(),
                                style: context.text.titleLarge?.copyWith(
                                  fontSize: isMobile ? 19 : 21,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isLoading
                                ? null
                                : () => context.pop(),
                            tooltip: 'cancel'.tr(),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.colors.error.withValues(alpha: .045),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colors.error.withValues(alpha: .18),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 21,
                              color: context.colors.error,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'remove_client_confirmation'.tr(
                                  namedArgs: {'name': clientName},
                                ),
                                style: context.text.bodyMedium?.copyWith(
                                  fontSize: isMobile ? 12.5 : 13.5,
                                  color: context.colors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      if (isSmallMobile)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PrimaryButtonWidget(
                              iconData: Icons.close_rounded,
                              iconSize: 18,
                              textColor: context.colors.primary,
                              iconeColor: context.colors.primary,
                              fontSize: 13,
                              buttonColor:
                                  context.colors.surfaceContainerHighest,
                              buttonText: 'cancel'.tr(),
                              borderRadius: AppRadius.sm,
                              onPress: isLoading
                                  ? null
                                  : () => context.pop(),
                            ),
                            const SizedBox(height: 9),
                            PrimaryButtonWidget(
                              iconData: Icons.delete_outline_rounded,
                              iconSize: 18,
                              iconeColor: context.colors.onError,
                              fontSize: 13,
                              buttonColor: context.colors.error,
                              buttonText:
                                  isLoading ? '' : 'remove'.tr(),
                              borderRadius: AppRadius.sm,
                              onPress: isLoading
                                  ? null
                                  : () {
                                      context
                                          .read<RemoveClientCubit>()
                                          .removeClient(
                                            clientId: clientId,
                                          );
                                    },
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButtonWidget(
                                iconData: Icons.close_rounded,
                                iconSize: isMobile ? 18 : 19,
                                textColor: context.colors.primary,
                                iconeColor: context.colors.primary,
                                fontSize: isMobile ? 13 : 14,
                                buttonColor:
                                    context.colors.surfaceContainerHighest,
                                buttonText: 'cancel'.tr(),
                                borderRadius: AppRadius.sm,
                                onPress: isLoading
                                    ? null
                                    : () => context.pop(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PrimaryButtonWidget(
                                iconData: Icons.delete_outline_rounded,
                                iconSize: isMobile ? 18 : 19,
                                iconeColor: context.colors.onError,
                                fontSize: isMobile ? 13 : 14,
                                buttonColor: context.colors.error,
                                buttonText:
                                    isLoading ? '' : 'remove'.tr(),
                                borderRadius: AppRadius.sm,
                                onPress: isLoading
                                    ? null
                                    : () {
                                        context
                                            .read<RemoveClientCubit>()
                                            .removeClient(
                                              clientId: clientId,
                                            );
                                      },
                              ),
                            ),
                          ],
                        ),

                      if (isLoading) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(10),
                          color: context.colors.error,
                          backgroundColor:
                              context.colors.error.withValues(alpha: .10),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
