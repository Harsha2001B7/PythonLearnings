import 'dart:convert';

/// Mirrors the backend's [UserMeResponse] Pydantic model.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    this.avatar,
    this.firstName,
    this.lastName,
    this.phone,
    this.country,
    this.status,
    this.isVerified,
    this.roleId,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;
  final String? avatar;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? country;
  final String? status;
  final bool? isVerified;
  final int? roleId;

  bool get isAdmin => role == 'Admin' || roleId == 1;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'User',
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      avatar: json['avatar'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      status: json['status'] as String?,
      isVerified: json['is_verified'] as bool?,
      roleId: json['role_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'permissions': permissions,
        'avatar': avatar,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'country': country,
        'status': status,
        'is_verified': isVerified,
        'role_id': roleId,
      };

  String toJsonString() => jsonEncode(toJson());

  static UserModel fromJsonString(String jsonString) =>
      UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  String get displayName => name.isNotEmpty ? name : email;
  String get firstName2 => firstName ?? name.split(' ').first;
}

/// Mirrors the backend's [Token] response.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'bearer',
    );
  }
}
