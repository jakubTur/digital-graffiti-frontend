
class CredentialRequest {
  final String login;
  final String password;
  CredentialRequest({
    required this.login,
    required this.password
  });

  Map<String, dynamic> toJson(){
    return {
      'login' : login,
      'password' : password,
    };
  }
}