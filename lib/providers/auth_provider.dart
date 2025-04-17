import 'dart:convert';
import 'dart:io';
import 'package:estate/services/base/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';


class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userData = prefs.getString('user');

      if (token != null && userData != null) {
        _currentUser = User.fromJson(json.decode(userData));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Oturum bilgileri yüklenirken bir hata oluştu';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        _error = 'Sunucu yanıtı işlenemedi: ${e.toString()}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        // Kontrol et: token ve user nesneleri var mı?
        if (responseData['token'] == null) {
          _error = 'Sunucudan token alınamadı';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        if (responseData['user'] == null) {
          _error = 'Kullanıcı bilgileri alınamadı';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Kullanıcı ve token bilgilerini SharedPreferences'a kaydet
        try {
          // Sunucudan gelen token'ı kaydet
          await prefs.setString('token', responseData['token']);

          // Kullanıcı bilgilerini kaydet
          final userJson = json.encode(responseData['user']);
          await prefs.setString('user', userJson);

          // Currentuser'ı güncelle
          _currentUser = User.fromJson(responseData['user']);
          _error = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (e) {
          _error = 'Kullanıcı bilgileri kaydedilirken hata: ${e.toString()}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = responseData['message'] ?? 'Giriş yapılırken bir hata oluştu';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Bağlantı hatası oluştu: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'username': username,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );

      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        _error = 'Sunucu yanıtı işlenemedi: ${e.toString()}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();

        // Kontrol et: token ve user nesneleri var mı?
        if (responseData['token'] == null) {
          _error = 'Sunucudan token alınamadı';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        if (responseData['user'] == null) {
          _error = 'Kullanıcı bilgileri alınamadı';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Kullanıcı ve token bilgilerini SharedPreferences'a kaydet
        try {
          // Sunucudan gelen token'ı kaydet
          await prefs.setString('token', responseData['token']);

          // Kullanıcı bilgilerini kaydet
          final userJson = json.encode(responseData['user']);
          await prefs.setString('user', userJson);

          // Currentuser'ı güncelle
          _currentUser = User.fromJson(responseData['user']);
          _error = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (e) {
          _error = 'Kullanıcı bilgileri kaydedilirken hata: ${e.toString()}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = responseData['message'] ?? 'Kayıt olurken bir hata oluştu';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Bağlantı hatası oluştu: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _error = 'Oturum bulunamadı';
        return false;
      }

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(data);
        await prefs.setString('user', json.encode(data));
        _error = null;
        return true;
      } else {
        _error = data['message'] ?? 'Profil güncellenirken bir hata oluştu';
        return false;
      }
    } catch (e) {
      _error = 'Bağlantı hatası oluştu';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadProfileImage(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _error = 'Oturum bulunamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/users/profile/image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final file = await http.MultipartFile.fromPath(
        'profileImage',
        imageFile.path,
      );

      request.files.add(file);

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user'] != null) {
          _currentUser = User.fromJson(data['user']);
          await prefs.setString('user', json.encode(data['user']));
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'message': 'Bilinmeyen hata'};
        _error =
            data['message'] ?? 'Profil fotoğrafı yüklenirken bir hata oluştu';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Bağlantı hatası oluştu';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Kullanıcı verilerini doğrudan güncelle
  Future<void> updateUserFromData(Map<String, dynamic> userData) async {
    try {
      // User modelini güncelle
      _currentUser = User.fromJson(userData);

      // SharedPreferences'a da kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(userData));

      // UI'ı güncelle
      notifyListeners();
    } catch (e) {
      _error = 'Kullanıcı verisi güncellenirken hata: $e';
      notifyListeners();
    }
  }
}
