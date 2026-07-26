class UserModel {
  final String uid;
  final String shopName;
  final String ownerName;
  final String email;
  final String activity;

  const UserModel({
    required this.uid,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.activity,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      shopName: map['shopName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      activity: map['activity'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shopName': shopName,
      'ownerName': ownerName,
      'email': email,
      'activity': activity,
    };
  }

  UserModel copyWith({
    String? uid,
    String? shopName,
    String? ownerName,
    String? email,
    String? activity,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      activity: activity ?? this.activity,
    );
  }
}