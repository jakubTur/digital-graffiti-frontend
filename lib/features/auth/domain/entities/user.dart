
class User {
  final String nickname;
  final String password;
  final bool active;
  final bool verified;
  final String email;

  User({
    required this.nickname,
    required this.password,
    required this.active,
    required this.verified,
    required this.email
  });
}