
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String nickname;
  final String email;
  final String role;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.nickname,
    required this.email,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        userId: json['userId'],
        nickname: json['nickname'],
        email: json['email'],
        role: json['role']);
  }
}