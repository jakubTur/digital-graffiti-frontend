import 'package:frontend/features/auth/domain/entities/user.dart';

class UserRequest {
  final String nickname;
  final String email;
  UserRequest({
    required this.nickname,
    required this.email,
  });
  Map<String, dynamic> toJson(){
    return {
      'nickname' : nickname,
      'email' : email,
    };
  }
}
