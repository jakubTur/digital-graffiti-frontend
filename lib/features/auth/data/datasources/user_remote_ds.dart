import '../../../../core/network/api_client.dart';
import '../models/user_request.dart';
import '../models/credential_request.dart';

class UserRemoteDataSource {
  final ApiClient api;
  UserRemoteDataSource(this.api);

  Future<void> postUser(UserRequest user) async {
    await api.post('/api/users/register', body: user.toJson());
  }
  Future<void> postCredential(CredentialRequest credential) async {
    await api.post('/api/credentials', body: credential.toJson());
  }
}