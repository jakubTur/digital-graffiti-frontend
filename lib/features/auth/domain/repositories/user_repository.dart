import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';

import '../entities/user.dart';

abstract class UserRepository {
  Future<void> registerUser(User user);
  Future<LoginResponse> login(LoginRequest request);
  Future<void> deleteUser(int id);
}
