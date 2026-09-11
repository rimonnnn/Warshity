class ShareInvitationModel {
  final String id;
  final String fromUid;
  final String fromEmail;
  final String toEmail;
  final String status;
  final DateTime createdAt;

  const ShareInvitationModel({
    required this.id,
    required this.fromUid,
    required this.fromEmail,
    required this.toEmail,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'fromEmail': fromEmail,
      'toEmail': toEmail,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShareInvitationModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ShareInvitationModel(
      id: id,
      fromUid: map['fromUid']?.toString() ?? '',
      fromEmail: map['fromEmail']?.toString() ?? '',
      toEmail: map['toEmail']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(
            map['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}