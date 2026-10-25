import 'package:frontend/features/auth/domain/entities/user.dart';

class UserRequest {
  final String nickname;
  final bool active;
  final bool verified;
  final String email;
  final String role;
  UserRequest({
    required this.nickname,
    required this.active,
    required this.verified,
    required this.email,
    required this.role
  });
  Map<String, dynamic> toJson(){
    return {
      'nickname' : nickname,
      'active' : active,
      'verified' : verified,
      'email' : email,
      'role' : role,
    };
  }
}
