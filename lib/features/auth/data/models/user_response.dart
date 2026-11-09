class UserResponse {
  UserResponse(
    this.nickname,
    this.active,
    this.bio,
    this.email,
    this.imageUrl,
    this.role,
    this.verified,
  );

  final String nickname;
  final bool active;
  final bool verified;
  final String email;
  final String role;
  final String bio;
  final String imageUrl;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      json['nickname'] as String? ?? '',
      json['active'] as bool? ?? true,
      json['bio'] as String? ?? '',
      json['email'] as String? ?? '',
      json['imageUrl'] as String? ?? '',
      json['role'] as String? ?? '',
      json['verified'] as bool? ?? false,
    );
  }
}
