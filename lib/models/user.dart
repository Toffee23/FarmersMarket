class User {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String? pushToken;
  final bool isVerified;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.pushToken,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      phone: json['phone'],
      pushToken: json['pushtoken'],
      isVerified: json['is_verified'] == 1,
    );
  }

  User copyWith({
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
  }) {
    return User(
      id: id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      pushToken: pushToken,
      isVerified: isVerified,
    );
  }
}
