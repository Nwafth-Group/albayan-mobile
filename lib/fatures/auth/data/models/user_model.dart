// ============================================
// FILE: lib/features/auth/data/models/user_model.dart
// ============================================

class UserModel {
  final String id;
  final String? userNumber;
  final String firstName;
  final String lastName;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? bio;
  final String? countryId;
  final String type;
  final String defaultLanguage;
  final String status;
  final bool termsAccepted;
  final String? lastLoginAt;
  final String createdAt;

  const UserModel({
    required this.id,
    this.userNumber,
    required this.firstName,
    required this.lastName,
    this.name,
    this.email,
    this.mobileNumber,
    this.bio,
    this.countryId,
    required this.type,
    required this.defaultLanguage,
    required this.status,
    required this.termsAccepted,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      userNumber: json['user_number']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      bio: json['bio']?.toString(),
      countryId: json['country_id']?.toString(),
      type: json['type']?.toString() ?? '',
      defaultLanguage: json['default_language']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      termsAccepted:
      json['terms_accepted'] == true ||
          json['terms_accepted'] == 1 ||
          json['terms_accepted'] == '1',
      lastLoginAt: json['last_login_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_number': userNumber,
    'first_name': firstName,
    'last_name': lastName,
    'name': name,
    'email': email,
    'mobile_number': mobileNumber,
    'bio': bio,
    'country_id': countryId,
    'type': type,
    'default_language': defaultLanguage,
    'status': status,
    'terms_accepted': termsAccepted,
    'last_login_at': lastLoginAt,
    'created_at': createdAt,
  };

  /// Returns name if available, otherwise first + last name.
  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!;
    }

    final fullName = '$firstName $lastName'.trim();
    return fullName.isNotEmpty ? fullName : 'User';
  }

  /// Whether the user has an email address.
  bool get hasEmail => email != null && email!.trim().isNotEmpty;

  /// Whether the user has a mobile number.
  bool get hasMobileNumber =>
      mobileNumber != null && mobileNumber!.trim().isNotEmpty;

  UserModel copyWith({
    String? id,
    String? userNumber,
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? mobileNumber,
    String? bio,
    String? countryId,
    String? type,
    String? defaultLanguage,
    String? status,
    bool? termsAccepted,
    String? lastLoginAt,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userNumber: userNumber ?? this.userNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      bio: bio ?? this.bio,
      countryId: countryId ?? this.countryId,
      type: type ?? this.type,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      status: status ?? this.status,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, displayName: $displayName, email: $email)';
  }
}