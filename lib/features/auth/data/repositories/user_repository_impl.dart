import 'package:flutter/cupertino.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:frontend/features/auth/data/models/user_response.dart';
import 'package:frontend/features/auth/data/models/user_update_request.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_ds.dart';
import '../models/credential_request.dart';
import '../models/user_request.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> registerUser(User user) async {
    debugPrint('registerUser');
    final userRequest = UserRequest(nickname: user.nickname, email: user.email);
    final credential = CredentialRequest(
      email: user.email,
      password: user.password,
    );
    await remoteDataSource.postUser(userRequest);
    await remoteDataSource.postCredential(credential);
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    return await remoteDataSource.login(request);
  }

  @override
  Future<void> deleteUser(int id) async {
    await remoteDataSource.deleteUser(id);
  }

  @override
  Future<UserResponse> getUser(int id) async {
    return await remoteDataSource.getUser(id);
  }

  @override
  Future<UserResponse> updateUser(int id, UserUpdateRequest request) async {
    return await remoteDataSource.updateUser(id, request);
  }

  @override
  Future<UserResponse> getUserByNickname(String nickname) async {
    return await remoteDataSource.getUserByNickname(nickname);
  }

  @override
  Future<void> updateEmail(int id, CredentialRequest request) async {
    await remoteDataSource.updateEmail(id, request);
  }

  @override
  Future<void> updatePassword(int id, CredentialRequest request) async {
    await remoteDataSource.updatePassword(id, request);
  }

  @override
  Future<void> uploadProfilePicture(int id, String imagePath) async {
    return await remoteDataSource.postProfilePicture(id, imagePath);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    return await remoteDataSource.deleteNotification(notificationId);
  }
  @override
  Future<void> resetPassword(String email) async {
    return await remoteDataSource.resetPassword(email);
  }
}
