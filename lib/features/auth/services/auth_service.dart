class AuthService {
  Future<bool> login({required String email, required String password}) async {
    return email.isNotEmpty && password.isNotEmpty;
  }
}
