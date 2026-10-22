import '../entities/user.dart';

abstract class UserRepository {
  Future<void> registerUser(User user);
}