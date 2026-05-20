
// ============================================
// FILE: lib/fatures/auth/data/models/user_model.dart
// ============================================

class UserModel {
  final String id;
  final String userNumber;
  final String firstName;
  final String lastName;
  final String name;
  final String? email;
  final String? mobileNumber;
  final String? bio;
  final String countryId;
  final String type;
  final String defaultLanguage;
  final String status;
  final bool termsAccepted;
  final String? lastLoginAt;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.userNumber,
    required this.firstName,
    required this.lastName,
    required this.name,
    this.email,
    this.mobileNumber,
    this.bio,
    required this.countryId,
    required this.type,
    required this.defaultLanguage,
    required this.status,
    required this.termsAccepted,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:              json['id']              as String,
      userNumber:      json['user_number']     as String,
      firstName:       json['first_name']      as String,
      lastName:        json['last_name']       as String,
      name:            json['name']            as String,
      email:           json['email']           as String?,
      mobileNumber:    json['mobile_number']   as String?,
      bio:             json['bio']             as String?,
      countryId:       json['country_id']      as String,
      type:            json['type']            as String,
      defaultLanguage: json['default_language'] as String,
      status:          json['status']          as String,
      termsAccepted:   (json['terms_accepted'] == true ||
          json['terms_accepted'] == 1),
      lastLoginAt:     json['last_login_at']   as String?,
      createdAt:       json['created_at']      as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':               id,
    'user_number':      userNumber,
    'first_name':       firstName,
    'last_name':        lastName,
    'name':             name,
    'email':            email,
    'mobile_number':    mobileNumber,
    'bio':              bio,
    'country_id':       countryId,
    'type':             type,
    'default_language': defaultLanguage,
    'status':           status,
    'terms_accepted':   termsAccepted,
    'last_login_at':    lastLoginAt,
    'created_at':       createdAt,
  };

  /// Display name helper
  String get displayName => name.isNotEmpty ? name : '$firstName $lastName';

  /// Whether the user verified via email
  bool get hasEmail => email != null && email!.isNotEmpty;
}