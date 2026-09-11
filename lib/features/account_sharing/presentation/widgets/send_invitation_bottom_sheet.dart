import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class SendInvitationBottomSheet extends StatefulWidget {
  const SendInvitationBottomSheet({super.key});

  @override
  State<SendInvitationBottomSheet> createState() =>
      _SendInvitationBottomSheetState();
}

class _SendInvitationBottomSheetState
    extends State<SendInvitationBottomSheet> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInvitation() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showAnimatedSnackDialog(
        context,
        message: 'email_is_required'.tr(),
        type: AnimatedSnackBarType.error,
      );
      return;
    }

    context.read<AccountSharingCubit>().sendInvitation(
          email: email,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AccountSharingCubit, AccountSharingState>(
      listener: (context, state) {
        if (state is AccountInvitationSent) {
          showAnimatedSnackDialog(
            context,
            message: 'invitation_sent_successfully'.tr(),
            type: AnimatedSnackBarType.success,
          );

          Navigator.of(context).pop();
        }

        if (state is AccountSharingError) {
          showAnimatedSnackDialog(
            context,
            message: state.message,
            type: AnimatedSnackBarType.error,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.r),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              12.h,
              20.w,
              20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 42.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(.25),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),

                SizedBox(height: 22.h),

                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(.12),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.share_outlined,
                        color: colors.primary,
                        size: 27.sp,
                      ),
                    ),

                    SizedBox(width: 14.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'share_account'.tr(),
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),

                          SizedBox(height: 5.h),

                          Text(
                            'share_account_description'.tr(),
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.4,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(.65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Email label
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'email'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _sendInvitation(),
                  decoration: InputDecoration(
                    hintText: 'enter_account_email'.tr(),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colors.primary,
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: colors.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 17.h,
                    ),
                  ),
                ),

                SizedBox(height: 22.h),

                // Send button
                BlocBuilder<AccountSharingCubit, AccountSharingState>(
                  builder: (context, state) {
                    final isLoading =
                        state is AccountSharingLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : _sendInvitation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16.r),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child:
                                    const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 9.w),
                                  Text(
                                    'send_invitation'.tr(),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}