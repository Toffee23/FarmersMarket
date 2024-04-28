class Address {
  Address({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.address,
    required this.city,
    required this.state,
    required this.phoneNumber,
    required this.additionalPhoneNumber,
    required this.isPrimary,
  });
  final int id;
  final int userId;
  final String fullName;
  final String address;
  final String city;
  final String state;
  final String phoneNumber;
  final String additionalPhoneNumber;
  final bool isPrimary;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['user_id'],
      fullName: json['fullname'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      phoneNumber: json['phone'],
      additionalPhoneNumber: json['additionalPhone'],
      isPrimary: json['isPrimary'] == 0 ? false : true,
    );
  }
}
