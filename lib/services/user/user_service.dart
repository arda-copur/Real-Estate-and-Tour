import 'dart:io';

import 'package:estate/services/base/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Kullanıcı profilini getir
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _apiService.get('/users/profile');
  }

  // Kullanıcı profilini güncelle
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? city,
    String? bio,
  }) async {
    return await _apiService.put('/users/profile', {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phone != null) 'phone': phone,
      if (age != null) 'age': age,
      if (city != null) 'city': city,
      if (bio != null) 'bio': bio,
    });
  }

  // Profil fotoğrafı yükle
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    return await _apiService.uploadFile(
      '/users/profile/image',
      'profileImage',
      imageFile,
    );
  }

  // Şifre değiştir
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _apiService.put('/users/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // Kaydedilmiş mülkleri getir
  Future<List<dynamic>> getSavedProperties() async {
    try {
      // Direkt olarak liste döndüren metodu kullan
      final savedProperties =
          await _apiService.getList('/users/saved/properties');

      return savedProperties;
    } catch (e) {
      return [];
    }
  }

  // Mülk kaydet
  Future<Map<String, dynamic>> saveProperty(String propertyId) async {
    return await _apiService.post('/users/saved/properties/$propertyId', {});
  }

  // Kaydedilmiş mülkü kaldır
  Future<Map<String, dynamic>> removeSavedProperty(String propertyId) async {
    return await _apiService.delete('/users/saved/properties/$propertyId');
  }

  // Kaydedilmiş deneyimleri getir
  Future<List<dynamic>> getSavedExperiences() async {
    try {
      // Direkt olarak liste döndüren metodu kullan
      final savedExperiences =
          await _apiService.getList('/users/saved/experiences');

      return savedExperiences;
    } catch (e) {
      return [];
    }
  }

  // Deneyim kaydet
  Future<Map<String, dynamic>> saveExperience(String experienceId) async {
    return await _apiService.post('/users/saved/experiences/$experienceId', {});
  }

  // Kaydedilmiş deneyimi kaldır
  Future<Map<String, dynamic>> removeSavedExperience(
      String experienceId) async {
    return await _apiService.delete('/users/saved/experiences/$experienceId');
  }

  // Kullanıcıyı ID ile getir (admin/ev sahibi)
  Future<Map<String, dynamic>> getUserById(String userId) async {
    return await _apiService.get('/users/$userId');
  }

  // Kullanıcının public profilini getir (herkese açık)
  Future<Map<String, dynamic>> getPublicUserProfile(String userId) async {
    return await _apiService.get('/users/public/$userId');
  }

  // Kullanıcı rolünü güncelle (admin)
  Future<Map<String, dynamic>> updateUserRole(
      String userId, String role) async {
    return await _apiService.put('/users/$userId/role', {'role': role});
  }
}
