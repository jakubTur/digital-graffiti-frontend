import 'package:flutter/cupertino.dart';

import '../datasources/user_remote_ds.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_request.dart';
import '../models/credential_request.dart';
import '../../domain/entities/user.dart';


class UserRepositoryImpl implements UserRepository{
  final UserRemoteDataSource remoteDataSource;
  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> registerUser(User user) async {
    debugPrint('registerUser');
    final userRequest = UserRequest(
        nickname: user.nickname,
        active: true,
        verified: false,
        email: user.email,
        role: 'user');
    final credential = CredentialRequest(
        login: user.nickname,
        password: user.password);
    await remoteDataSource.postUser(userRequest);
    await remoteDataSource.postCredential(credential);
  }
}
