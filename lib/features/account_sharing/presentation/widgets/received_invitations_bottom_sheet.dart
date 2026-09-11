import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';
import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class ReceivedInvitationsBottomSheet extends StatelessWidget {
  const ReceivedInvitationsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AccountSharingCubit, AccountSharingState>(
      listener: (context, state) async {
        if (state is AccountSharingError) {
          showAnimatedSnackDialog(
            context,
            message: state.message,
            type: AnimatedSnackBarType.error,
          );
        }

        if (state is AccountInvitationResponded) {
          showAnimatedSnackDialog(
            context,
            message: 'invitation_response_successfully'.tr(),
            type: AnimatedSnackBarType.success,
          );

          await Future.delayed(const Duration(seconds: 1));

          if (!context.mounted) return;

          context.goNamed(AppRoutes.splashScreen);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(.25),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),

                SizedBox(height: 22.h),

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
                        Icons.mail_outline_rounded,
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
                            'account_invitations'.tr(),
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            'account_invitations_description'.tr(),
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.4,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(.65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close_rounded, size: 24.sp),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                StreamBuilder<List<ShareInvitationModel>>(
                  stream: context
                      .read<AccountSharingCubit>()
                      .watchReceivedInvitations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 35.h),
                        child: SizedBox(
                          width: 28.w,
                          height: 28.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.primary,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 42.sp,
                              color: colors.error,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'something_went_wrong'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      );
                    }

                    final invitations = snapshot.data ?? [];

                    if (invitations.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.h),
                        child: Column(
                          children: [
                            Container(
                              width: 70.w,
                              height: 70.w,
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(.10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mark_email_read_outlined,
                                size: 34.sp,
                                color: colors.primary,
                              ),
                            ),

                            SizedBox(height: 14.h),

                            Text(
                              'no_pending_invitations'.tr(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 5.h),

                            Text(
                              'no_invitations_description'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(.60),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 430.h),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: invitations.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return _InvitationCard(
                            invitation: invitations[index],
                          );
                        },
                      ),
                    );
                  },
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation});

  final ShareInvitationModel invitation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(.35),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.primary.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: colors.primary,
                  size: 23.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'account_share_request'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      invitation.fromEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Text(
            'account_share_invitation_description'.tr(),
            style: TextStyle(
              fontSize: 13.5.sp,
              height: 1.45,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(.70),
            ),
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AccountSharingCubit>().respondToInvitation(
                      invitationId: invitation.id,
                      accept: false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    side: BorderSide(color: colors.error.withOpacity(.65)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'reject'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.error,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AccountSharingCubit>().respondToInvitation(
                      invitationId: invitation.id,
                      accept: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'accept'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
