class UserUpdateRequest {
  final String? nickname;
  final String? email;
  final bool verified;
  final bool active;
  final String? bio;

  const UserUpdateRequest({
    required this.nickname,
    required this.email,
    required this.verified,
    required this.active,
    required this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'email': email,
      'verified': verified,
      'active': active,
      'bio': bio,
    };
  }
}
