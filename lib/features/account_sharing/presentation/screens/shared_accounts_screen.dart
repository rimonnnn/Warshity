import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

import 'shared_accounts_body.dart';
import 'shared_accounts_data.dart';
import 'shared_accounts_delete_dialog.dart';

class SharedAccountsScreen extends StatefulWidget {
  const SharedAccountsScreen({super.key});

  @override
  State<SharedAccountsScreen> createState() => _SharedAccountsScreenState();
}

class _SharedAccountsScreenState extends State<SharedAccountsScreen> {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  bool _isLoading = true;

  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _startRealtimeWatchers();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _startRealtimeWatchers() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase();

    if (user == null || email == null || email.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final firestore = FirebaseFirestore.instance;

    _subscriptions.addAll([
      firestore
          .collection('account_shares')
          .where('fromUid', isEqualTo: user.uid)
          .snapshots()
          .listen((_) => _reloadData()),
      firestore
          .collection('account_shares')
          .where('toEmail', isEqualTo: email)
          .snapshots()
          .listen((_) => _reloadData()),
      firestore
          .collection('user_shared_accounts')
          .doc(user.uid)
          .snapshots()
          .listen((_) => _reloadData()),
    ]);

    _reloadData();
  }

  Future<void> _reloadData() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase();

    if (user == null || email == null || email.isEmpty) {
      if (!mounted) return;

      setState(() {
        _items = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final cubit = context.read<AccountSharingCubit>();

      final invitations = await fetchInvitations(uid: user.uid, email: email);

      final connections = await cubit.getActiveSharedAccounts();

      final items = buildVisibleItems(
        invitations: invitations,
        connections: connections,
        currentEmail: email,
      );

      if (!mounted) return;

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      _showSnackBar('${'failed_to_load_shared_accounts'.tr()}: $e');
    }
  }

  Future<void> _deleteSharedAccount(String connectionId) async {
    final confirmed = await showDeleteSharedAccountDialog(context);

    if (!confirmed || !mounted) {
      return;
    }

    try {
      await context.read<AccountSharingCubit>().deleteSharedAccount(
        connectionId,
      );
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('${'failed_to_delete_shared_account'.tr()}: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          'shared_accounts'.tr(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocListener<AccountSharingCubit, AccountSharingState>(
        listener: (context, state) {
          if (state is AccountSharedAccountDeleted ||
              state is AccountSharingStatusChanged) {
            _reloadData();
            return;
          }

          if (state is AccountSharingError) {
            _showSnackBar(state.message);
          }
        },
        child: SharedAccountsBody(
          isLoading: _isLoading,
          items: _items,
          onRefresh: _reloadData,
          onDelete: _deleteSharedAccount,
        ),
      ),
    );
  }
}
