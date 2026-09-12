import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

class SharedAccountsScreen extends StatefulWidget {
  const SharedAccountsScreen({super.key});

  @override
  State<SharedAccountsScreen> createState() => _SharedAccountsScreenState();
}

class _SharedAccountsScreenState extends State<SharedAccountsScreen> {
  String? sharedAccountId;
  String? otherUserEmail;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSharedAccount();
  }

  Future<void> _loadSharedAccount() async {
    final cubit = context.read<AccountSharingCubit>();

    try {
      final id = await cubit.getSharedAccountId();

      if (!mounted) return;

      if (id == null || id.isEmpty) {
        setState(() {
          sharedAccountId = null;
          otherUserEmail = null;
          isLoading = false;
        });

        return;
      }

      final invitationSnapshot = await FirebaseFirestore.instance
          .collection('account_shares')
          .doc(id)
          .get();

      if (!mounted) return;

      String? email;

      if (invitationSnapshot.exists) {
        final data = invitationSnapshot.data();

        final fromEmail = data?['fromEmail']?.toString().trim().toLowerCase();
        final toEmail = data?['toEmail']?.toString().trim().toLowerCase();

        final currentEmail = FirebaseAuth.instance.currentUser?.email
            ?.trim()
            .toLowerCase();

        if (fromEmail != null &&
            fromEmail.isNotEmpty &&
            fromEmail != currentEmail) {
          email = fromEmail;
        } else if (toEmail != null &&
            toEmail.isNotEmpty &&
            toEmail != currentEmail) {
          email = toEmail;
        }
      }

      setState(() {
        sharedAccountId = id;
        otherUserEmail = email;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteSharedAccount() async {
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'delete_shared_account'.tr(),
          ),
          content: Text(
            'delete_shared_account_confirmation'.tr(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                'cancel'.tr(),
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: 18.sp,
                ),
              ),
            ),

            SizedBox(width: 8.w),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  80.w,
                  40.h,
                ),
                backgroundColor: context.colors.error,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);

                context
                    .read<AccountSharingCubit>()
                    .deleteSharedAccount();
              },
              child: Text(
                'delete'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shared Accounts'.tr())),
      body: BlocListener<AccountSharingCubit, AccountSharingState>(
        listener: (context, state) {
          if (state is AccountSharedAccountDeleted) {
            context.goNamed(AppRoutes.splashScreen);
          }

          if (state is AccountSharingStatusChanged) {
            if (state.sharedAccountId == null) {
              setState(() {
                sharedAccountId = null;
                otherUserEmail = null;
              });
            }
          }

          if (state is AccountSharingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sharedAccountId == null) {
      return Center(
        child: Text('No shared accounts'.tr(), style: TextStyle(fontSize: 18)),
      );
    }

    return BlocBuilder<AccountSharingCubit, AccountSharingState>(
      builder: (context, state) {
        final deleting = state is AccountSharingLoading;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.people)),

                title: Text('Shared Account'.tr()),

                subtitle: Text(
                  otherUserEmail?.isNotEmpty == true
                      ? otherUserEmail!
                      : 'Unknown account'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                trailing: deleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: _deleteSharedAccount,
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
