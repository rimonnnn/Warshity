import 'package:cloud_firestore/cloud_firestore.dart';

import 'shared_accounts_utils.dart';

/// Fetches all invitations sent by or received by the current user,
/// merged by document id.
Future<List<Map<String, dynamic>>> fetchInvitations({
  required String uid,
  required String email,
}) async {
  final shares = FirebaseFirestore.instance.collection('account_shares');

  final sentSnapshot = await shares.where('fromUid', isEqualTo: uid).get();

  final receivedSnapshot = await shares
      .where('toEmail', isEqualTo: email)
      .get();

  final Map<String, Map<String, dynamic>> invitationsById = {};

  for (final doc in [...sentSnapshot.docs, ...receivedSnapshot.docs]) {
    invitationsById[doc.id] = {'id': doc.id, ...doc.data()};
  }

  return invitationsById.values.toList();
}

/// Builds the list of items shown on screen:
/// connected first, then pending, then history, each sorted by email.
List<Map<String, dynamic>> buildVisibleItems({
  required List<Map<String, dynamic>> invitations,
  required List<Map<String, dynamic>> connections,
  required String? currentEmail,
}) {
  final List<Map<String, dynamic>> visibleItems = [];
  final Set<String> connectedEmails = {};

  // 1) Active connections
  for (final connection in connections) {
    final connectionId = connection['id']?.toString();

    if (connectionId == null || connectionId.isEmpty) {
      continue;
    }

    final otherEmail = getOtherConnectionEmail(connection, currentEmail);

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

  // 2) Group invitations by the other party's email
  final Map<String, List<Map<String, dynamic>>> groupedByEmail = {};

  for (final invitation in invitations) {
    final otherEmail = getOtherEmail(invitation, currentEmail);

    if (otherEmail.isEmpty) {
      continue;
    }

    groupedByEmail.putIfAbsent(otherEmail, () => []).add(invitation);
  }

  // 3) Pending / history items
  for (final entry in groupedByEmail.entries) {
    final otherEmail = entry.key;

    if (connectedEmails.contains(otherEmail.toLowerCase())) {
      continue;
    }

    final item = _buildInvitationItem(otherEmail, entry.value);

    if (item != null) {
      visibleItems.add(item);
    }
  }

  visibleItems.sort((a, b) {
    final priorityA = getTypePriority(a['type']?.toString());
    final priorityB = getTypePriority(b['type']?.toString());

    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }

    return a['email'].toString().toLowerCase().compareTo(
      b['email'].toString().toLowerCase(),
    );
  });

  return visibleItems;
}

Map<String, dynamic>? _buildInvitationItem(
  String otherEmail,
  List<Map<String, dynamic>> invitations,
) {
  final hasPending = invitations.any((i) => getStatus(i) == 'pending');

  if (hasPending) {
    return {'type': 'pending', 'email': otherEmail, 'status': 'pending'};
  }

  sortByNewest(invitations);

  final latestStatus = getStatus(invitations.first);

  if (latestStatus == 'rejected') {
    return {'type': 'history', 'email': otherEmail, 'status': 'rejected'};
  }

  if (latestStatus == 'accepted') {
    return {'type': 'history', 'email': otherEmail, 'status': 'disconnected'};
  }

  return null;
}
