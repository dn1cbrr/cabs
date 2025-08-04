class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final DateTime? birthday;
  final String? phone;
  final DateTime? expirationDate;
  final String? profilePhoto;
  final String? licenseName;
  final String? licenseNumber;
  final String? licenseAddress;
  final String? licenseCodes;
  final DateTime? licenseExpiration;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.birthday,
    this.phone,
    this.expirationDate,
    this.profilePhoto,
    this.licenseName,
    this.licenseNumber,
    this.licenseAddress,
    this.licenseCodes,
    this.licenseExpiration,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      phone: json['phone_number'],
      expirationDate: json['expiration_date'] != null ? DateTime.parse(json['expiration_date']) : null,
      profilePhoto: json['profile_photo'],
      licenseName: json['license_name'],
      licenseNumber: json['license_number'],
      licenseAddress: json['license_address'],
      licenseCodes: json['license_codes'],
      licenseExpiration: json['license_expiration'] != null ? DateTime.parse(json['license_expiration']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'birthday': birthday?.toIso8601String(),
      'phone_number': phone,
      'expiration_date': expirationDate?.toIso8601String(),
      'profile_photo': profilePhoto,
      'license_name': licenseName,
      'license_number': licenseNumber,
      'license_address': licenseAddress,
      'license_codes': licenseCodes,
      'license_expiration': licenseExpiration?.toIso8601String(),
    };
  }
}
