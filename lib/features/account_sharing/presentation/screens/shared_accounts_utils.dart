import 'package:cloud_firestore/cloud_firestore.dart';

/// Returns the email of the other party in an invitation
/// (empty string if it can't be determined).
String getOtherEmail(Map<String, dynamic> invitation, String? currentEmail) {
  final fromEmail = invitation['fromEmail']?.toString().trim().toLowerCase();
  final toEmail = invitation['toEmail']?.toString().trim().toLowerCase();

  if (fromEmail != null && fromEmail.isNotEmpty && fromEmail != currentEmail) {
    return fromEmail;
  }

  if (toEmail != null && toEmail.isNotEmpty && toEmail != currentEmail) {
    return toEmail;
  }

  return '';
}

/// Returns the email of the other party in an active connection.
String getOtherConnectionEmail(
  Map<String, dynamic> connection,
  String? currentEmail,
) {
  final emails = connection['emails'];

  if (emails is! List) {
    return '';
  }

  final normalizedEmails = emails
      .map((e) => e.toString().trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList();

  for (final connectionEmail in normalizedEmails) {
    if (currentEmail != null && connectionEmail != currentEmail) {
      return connectionEmail;
    }
  }

  return normalizedEmails.isNotEmpty ? normalizedEmails.first : '';
}

String getStatus(Map<String, dynamic> invitation) {
  final status = invitation['status']?.toString().trim().toLowerCase();

  if (status == null || status.isEmpty) {
    return 'pending';
  }

  return status;
}

int getTypePriority(String? type) {
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

DateTime toDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}

/// Sorts invitations by `createdAt`, newest first.
void sortByNewest(List<Map<String, dynamic>> invitations) {
  invitations.sort((a, b) {
    return toDateTime(b['createdAt']).compareTo(toDateTime(a['createdAt']));
  });
}
