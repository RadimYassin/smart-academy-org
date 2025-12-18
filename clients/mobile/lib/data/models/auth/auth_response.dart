class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isVerified;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isVerified,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      // Backend uses snake_case for these fields
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? json['refreshToken'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? json['isVerified'] as bool? ?? false,
      // These are camelCase
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? json['firstName'] as String? ?? '',
      lastName: json['last_name'] as String? ?? json['lastName'] as String? ?? '',
      role: json['role'] as String? ?? 'STUDENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'isVerified': isVerified,
    };
  }
}

