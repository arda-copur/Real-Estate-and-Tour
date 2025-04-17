import 'package:estate/services/base/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Kayıt ol
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    return await _apiService.post('/auth/register', {
      'email': email,
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (phone != null) 'phone': phone,
    });
  }

  // Giriş yap
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.containsKey('token')) {
      await _apiService.saveToken(response['token']);
    }

    return response;
  }

  // Çıkış yap
  Future<void> logout() async {
    await _apiService.removeToken();
  }

  // Mevcut kullanıcıyı getir
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _apiService.get('/auth/me');
  }

  // Token doğrula
  Future<bool> verifyToken(String token) async {
    try {
      final response =
          await _apiService.post('/auth/verify-token', {'token': token});
      return response['valid'] == true;
    } catch (e) {
      return false;
    }
  }

  // Şifre sıfırlama isteği
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _apiService.post('/auth/forgot-password', {'email': email});
  }
}
