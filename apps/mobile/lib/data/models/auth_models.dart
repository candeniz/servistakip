import '../../core/constants/roles.dart';

/// Oturum kullanıcısı.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.tenantId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.profilePhoto,
    required this.tenantName,
  });

  final String id;
  final String? tenantId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final Role role;
  final String status;
  final String? profilePhoto;
  final String? tenantName;

  String get fullName => '$firstName $lastName';

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String?,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        role: Role.fromValue(json['role'] as String),
        status: json['status'] as String? ?? 'active',
        profilePhoto: json['profile_photo'] as String?,
        tenantName: json['tenant_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id': tenantId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'role': role.value,
        'status': status,
        'profile_photo': profilePhoto,
        'tenant_name': tenantName,
      };
}

/// Access/refresh token çifti.
class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken, required this.expiresIn});

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn: (json['expires_in'] as num?)?.toInt() ?? 900,
      );
}

/// Login yanıtı.
class LoginResult {
  const LoginResult({required this.user, required this.tokens});
  final AuthUser user;
  final AuthTokens tokens;

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      );
}
