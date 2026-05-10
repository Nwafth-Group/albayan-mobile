class UserModel {
  final int? id;
  final String? email;
  final String? phoneNumber;
  final String? name;
  final int? modelId;

  UserModel({
    this.id,
    this.email,
    this.phoneNumber,
    this.name,
    this.modelId
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      name: json['name'],
      modelId: json['model_id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'name': name,
      'model_id': modelId
    };
  }
}

class AuthResponseModel {
  final bool success;
  final String? message;
  final UserModel? user;
  final String? token;
  final String? verificationId;

  AuthResponseModel({
    required this.success,
    this.message,
    this.user,
    this.token,
    this.verificationId,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? (json['status'] == 200),
      message: json['message'],
      token: json['params']?['token'],
      user: json['data']!=null ? UserModel.fromJson(json['data']) : null,
      verificationId: json['verification_id'] ?? json['verificationId'],
    );
  }
}
