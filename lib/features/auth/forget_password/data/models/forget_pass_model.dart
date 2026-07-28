class ForgetPassModel {
  final String email;

  const ForgetPassModel({required this.email});

  factory ForgetPassModel.fromMap(Map<String, dynamic> map) {
    return ForgetPassModel(email: map['email'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'email': email};
  }

  ForgetPassModel copyWith({String? email}) {
    return ForgetPassModel(email: email ?? this.email);
  }
}
