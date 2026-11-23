import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:frontend/features/auth/data/models/user_response.dart';
import 'package:frontend/features/auth/data/models/user_update_request.dart';

import '../../data/models/credential_request.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<void> registerUser(User user);
  Future<LoginResponse> login(LoginRequest request);
  Future<void> deleteUser(int id);
  Future<UserResponse> getUser(int id);
  Future<UserResponse> updateUser(int id, UserUpdateRequest request);
  Future<void> updateEmail(int id, CredentialRequest request);
  Future<void> updatePassword(int id, CredentialRequest request);
  Future<void> uploadProfilePicture(int id, String imagePath);
  Future<UserResponse> getUserByNickname(String nickname);
  Future<void> deleteNotification(String notificationId);
}
