import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warshity/core/config/feature_flags.dart';
import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';

part 'account_sharing_connections_mixin.dart';
part 'account_sharing_core_mixin.dart';
part 'account_sharing_delete_mixin.dart';
part 'account_sharing_invitations_mixin.dart';
part 'account_sharing_merge_mixin.dart';
part 'account_sharing_respond_mixin.dart';
part 'account_sharing_separation_mixin.dart';

class AccountSharingRemoteDataSource
    with
        _AccountSharingCore,
        _AccountSharingConnections,
        _AccountSharingInvitations,
        _AccountSharingMerge,
        _AccountSharingRespond,
        _AccountSharingSeparation,
        _AccountSharingDelete {
  AccountSharingRemoteDataSource(this.firestore, this.auth);

  @override
  final FirebaseFirestore firestore;

  @override
  final FirebaseAuth auth;

  static const int maxConnections = _maxConnections;

  int _cachedConnectionsCount = 0;

  int getActiveConnectionsCount() {
    return _cachedConnectionsCount;
  }

  void updateConnectionsCount(int count) {
    _cachedConnectionsCount = count;
  }
}
