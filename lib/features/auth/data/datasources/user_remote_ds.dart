import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';

import '../../../../core/network/api_client.dart';
import '../models/credential_request.dart';
import '../models/user_request.dart';

class UserRemoteDataSource {
  final ApiClient api;
  UserRemoteDataSource(this.api);

  Future<void> postUser(UserRequest user) async {
    await api.post('/api/users/register', body: user.toJson());
  }

  Future<void> deleteUser(int id) async {
    await api.delete('/api/users/delete/$id');
  }

  Future<void> postCredential(CredentialRequest credential) async {
    await api.post('/api/credentials', body: credential.toJson());
  }

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    final response = await api.post(
      '/auth/login',
      body: loginRequest.toJson(),
      expectedStatusCode: 200,
    );
    return LoginResponse.fromJson(Map<String, dynamic>.from(response as Map));
  }
}
