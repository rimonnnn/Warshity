import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/account_history_card_widget.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/connected_account_card_widget.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/empty_shared_accounts_widget.dart';
import 'package:warshity/features/account_sharing/presentation/widgets/pending_invitation_card_widget.dart';

class SharedAccountsScreen extends StatefulWidget {
  const SharedAccountsScreen({super.key});

  @override
  State<SharedAccountsScreen> createState() => _SharedAccountsScreenState();
}

class _SharedAccountsScreenState extends State<SharedAccountsScreen> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sentSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _receivedSubscription;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _mappingSubscription;

  bool _isLoading = true;

  List<Map<String, dynamic>> _allInvitations = [];

  @override
  void initState() {
    super.initState();
    _startRealtimeWatchers();
  }

  @override
  void dispose() {
    _sentSubscription?.cancel();
    _receivedSubscription?.cancel();
    _mappingSubscription?.cancel();
    super.dispose();
  }

  void _startRealtimeWatchers() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      return;
    }

    final email = user.email?.trim().toLowerCase();

    if (email == null || email.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      return;
    }

    _sentSubscription = FirebaseFirestore.instance
        .collection('account_shares')
        .where('fromUid', isEqualTo: user.uid)
        .snapshots()
        .listen((_) {
          _reloadData();
        });

    _receivedSubscription = FirebaseFirestore.instance
        .collection('account_shares')
        .where('toEmail', isEqualTo: email)
        .snapshots()
        .listen((_) {
          _reloadData();
        });

    _mappingSubscription = FirebaseFirestore.instance
        .collection('user_shared_accounts')
        .doc(user.uid)
        .snapshots()
        .listen((_) {
          _reloadData();
        });

    _reloadData();
  }

  Future<void> _reloadData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _allInvitations = [];
        _isLoading = false;
      });

      return;
    }

    final email = user.email?.trim().toLowerCase();

    if (email == null || email.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _allInvitations = [];
        _isLoading = false;
      });

      return;
    }

    try {
      final sentSnapshot = await FirebaseFirestore.instance
          .collection('account_shares')
          .where('fromUid', isEqualTo: user.uid)
          .get();

      final receivedSnapshot = await FirebaseFirestore.instance
          .collection('account_shares')
          .where('toEmail', isEqualTo: email)
          .get();

      final Map<String, Map<String, dynamic>> invitationsById = {};

      for (final doc in sentSnapshot.docs) {
        invitationsById[doc.id] = {'id': doc.id, ...doc.data()};
      }

      for (final doc in receivedSnapshot.docs) {
        invitationsById[doc.id] = {'id': doc.id, ...doc.data()};
      }

      final allInvitations = invitationsById.values.toList();

      final connections = await context
          .read<AccountSharingCubit>()
          .getActiveSharedAccounts();

      final Map<String, List<Map<String, dynamic>>> groupedByEmail = {};

      for (final invitation in allInvitations) {
        final otherEmail = _getOtherEmail(invitation);

        if (otherEmail.isEmpty) {
          continue;
        }

        groupedByEmail.putIfAbsent(otherEmail, () => []).add(invitation);
      }

      final List<Map<String, dynamic>> visibleItems = [];

      final Set<String> connectedEmails = {};

      for (final connection in connections) {
        final connectionId = connection['id']?.toString();

        if (connectionId == null || connectionId.isEmpty) {
          continue;
        }

        final otherEmail = _getOtherConnectionEmail(connection, user.uid);

        if (otherEmail.isEmpty) {
          continue;
        }

        connectedEmails.add(otherEmail.toLowerCase());

        visibleItems.add({
          'type': 'connected',
          'email': otherEmail,
          'status': 'connected',
          'connectionId': connectionId,
        });
      }

      for (final entry in groupedByEmail.entries) {
        final otherEmail = entry.key;

        if (connectedEmails.contains(otherEmail.toLowerCase())) {
          continue;
        }

        final invitations = entry.value;

        final pendingInvitations = invitations
            .where((invitation) => _getStatus(invitation) == 'pending')
            .toList();

        if (pendingInvitations.isNotEmpty) {
          pendingInvitations.sort((a, b) {
            return _toDateTime(
              b['createdAt'],
            ).compareTo(_toDateTime(a['createdAt']));
          });

          visibleItems.add({
            'type': 'pending',
            'email': otherEmail,
            'status': 'pending',
          });

          continue;
        }

        invitations.sort((a, b) {
          return _toDateTime(
            b['createdAt'],
          ).compareTo(_toDateTime(a['createdAt']));
        });

        final latest = invitations.first;

        final latestStatus = _getStatus(latest);

        if (latestStatus == 'rejected') {
          visibleItems.add({
            'type': 'history',
            'email': otherEmail,
            'status': 'rejected',
          });

          continue;
        }

        if (latestStatus == 'accepted') {
          visibleItems.add({
            'type': 'history',
            'email': otherEmail,
            'status': 'disconnected',
          });
        }
      }

      visibleItems.sort((a, b) {
        final priorityA = _getTypePriority(a['type']?.toString());

        final priorityB = _getTypePriority(b['type']?.toString());

        if (priorityA != priorityB) {
          return priorityA.compareTo(priorityB);
        }

        return a['email'].toString().toLowerCase().compareTo(
          b['email'].toString().toLowerCase(),
        );
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _allInvitations = visibleItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'failed_to_load_shared_accounts'.tr()}: $e')),
      );
    }
  }

  String _getOtherConnectionEmail(
    Map<String, dynamic> connection,
    String currentUid,
  ) {
    final emails = connection['emails'];

    if (emails is! List) {
      return '';
    }

    final normalizedEmails = emails
        .map((e) => e.toString().trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    final currentEmail = FirebaseAuth.instance.currentUser?.email
        ?.trim()
        .toLowerCase();

    for (final connectionEmail in normalizedEmails) {
      if (currentEmail != null && connectionEmail != currentEmail) {
        return connectionEmail;
      }
    }

    return normalizedEmails.isNotEmpty ? normalizedEmails.first : '';
  }

  int _getTypePriority(String? type) {
    switch (type) {
      case 'connected':
        return 0;

      case 'pending':
        return 1;

      case 'history':
        return 2;

      default:
        return 3;
    }
  }

  String _getOtherEmail(Map<String, dynamic> invitation) {
    final currentEmail = FirebaseAuth.instance.currentUser?.email
        ?.trim()
        .toLowerCase();

    final fromEmail = invitation['fromEmail']?.toString().trim().toLowerCase();

    final toEmail = invitation['toEmail']?.toString().trim().toLowerCase();

    if (fromEmail != null &&
        fromEmail.isNotEmpty &&
        fromEmail != currentEmail) {
      return fromEmail;
    }

    if (toEmail != null && toEmail.isNotEmpty && toEmail != currentEmail) {
      return toEmail;
    }

    return '';
  }

  String _getStatus(Map<String, dynamic> invitation) {
    final status = invitation['status']?.toString().trim().toLowerCase();

    if (status == null || status.isEmpty) {
      return 'pending';
    }

    return status;
  }

  DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _deleteSharedAccount(String connectionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('delete_shared_account'.tr()),
          content: Text('delete_shared_account_confirmation'.tr()),
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
                minimumSize: Size(80.w, 40.h),
                backgroundColor: context.colors.error,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                'delete'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await context.read<AccountSharingCubit>().deleteSharedAccount(
        connectionId,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'failed_to_delete_shared_account'.tr()}: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('shared_accounts'.tr())),
      body: BlocListener<AccountSharingCubit, AccountSharingState>(
        listener: (context, state) {
          if (state is AccountSharedAccountDeleted) {
            _reloadData();
            return;
          }

          if (state is AccountSharingStatusChanged) {
            _reloadData();
            return;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allInvitations.isEmpty) {
      return const EmptySharedAccountsWidget();
    }

    final connectedAccounts = _allInvitations
        .where((item) => item['type'] == 'connected')
        .toList();

    final pendingAccounts = _allInvitations
        .where((item) => item['type'] == 'pending')
        .toList();

    final historyAccounts = _allInvitations
        .where((item) => item['type'] == 'history')
        .toList();

    return RefreshIndicator(
      onRefresh: _reloadData,
      child: ListView(
        padding: EdgeInsets.all(16.sp),
        children: [
          if (connectedAccounts.isNotEmpty) ...[
            Text(
              'connected_accounts'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h),
            ...connectedAccounts.map((item) {
              final connectionId = item['connectionId']?.toString() ?? '';

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: ConnectedAccountCardWidget(
                  email: item['email'].toString(),
                  onDelete: connectionId.isEmpty
                      ? null
                      : () => _deleteSharedAccount(connectionId),
                  isDeleting: false,
                ),
              );
            }),
            SizedBox(height: 10.h),
          ],

          if (pendingAccounts.isNotEmpty) ...[
            Text(
              'pending_invitations'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h),
            ...pendingAccounts.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: PendingInvitationCardWidget(
                  email: item['email'].toString(),
                ),
              );
            }),
            SizedBox(height: 10.h),
          ],

          if (historyAccounts.isNotEmpty) ...[
            Text(
              'invitation_history'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h),
            ...historyAccounts.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: AccountHistoryCardWidget(
                  email: item['email'].toString(),
                  status: item['status'].toString(),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
