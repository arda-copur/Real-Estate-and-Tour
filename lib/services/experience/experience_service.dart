// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:estate/services/base/api_service.dart';

class ExperienceService {
  final ApiService _apiService = ApiService();

  // Tüm deneyimleri getir
  Future<Map<String, dynamic>> getAllExperiences({
    String? location,
    String? category,
    int? priceMin,
    int? priceMax,
    int page = 1,
    int limit = 10,
  }) async {
    String query = '/experiences?page=$page&limit=$limit';
    if (location != null) query += '&location=$location';
    if (category != null) query += '&category=$category';
    if (priceMin != null) query += '&price_min=$priceMin';
    if (priceMax != null) query += '&price_max=$priceMax';

    return await _apiService.get(query);
  }

  // Deneyimleri getir (liste olarak döndürür)
  Future<List<dynamic>> getExperiences({
    String? location,
    String? category,
    int? priceMin,
    int? priceMax,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getAllExperiences(
      location: location,
      category: category,
      priceMin: priceMin,
      priceMax: priceMax,
      page: page,
      limit: limit,
    );

    return response['experiences'] ?? [];
  }

  // Kategoriye göre deneyimleri getir
  Future<Map<String, dynamic>> getExperiencesByCategory(
    String category, {
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiService
        .get('/experiences/categories/$category?page=$page&limit=$limit');
  }

  // Deneyimi ID ile getir
  Future<Map<String, dynamic>> getExperienceById(String id) async {
    return await _apiService.get('/experiences/$id');
  }

  // Ev sahibinin deneyimlerini getir
  Future<List<dynamic>> getMyExperiences() async {
    final response = await _apiService.get('/experiences/host/my-experiences');
    return response['experiences'] ?? [];
  }

  // Yeni deneyim oluştur
  Future<Map<String, dynamic>> createExperience({
    required String title,
    required String subtitle,
    required String description,
    required int price,
    required String duration,
    required String location,
    required String category,
    required int maxGuests,
    required File image,
    String? currency,
    Map<String, dynamic>? coordinates,
    List<String>? includes,
    List<String>? languages,
    List<String>? tags,
    List<Map<String, dynamic>>? schedule,
  }) async {
    // Multipart request oluştur
    final token = await _apiService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/experiences'),
    );

    //Token
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Fotoğraf
    request.files.add(
      await http.MultipartFile.fromPath('experienceImage', image.path),
    );

    // Form verileri
    request.fields['title'] = title;
    request.fields['subtitle'] = subtitle;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['duration'] = duration;
    request.fields['location'] = location;
    request.fields['category'] = category;
    request.fields['maxGuests'] = maxGuests.toString();

    if (currency != null) {
      request.fields['currency'] = currency;
    }

    if (coordinates != null) {
      request.fields['coordinates'] = jsonEncode(coordinates);
    }

    if (includes != null && includes.isNotEmpty) {
      // Temiz ve tutarlı bir yaklaşım kullanıyoruz

      // 1. Açık ve anlaşılır şekilde "included" alanını doğrudan JSON olarak gönder
      request.fields['included'] = jsonEncode(includes);

      // 2. Alternatif olarak backend'in kontrol edebileceği bir diğer format
      request.fields['included_csv'] = includes.join(',');

      // 3. Ek olarak includes array parametresi de gönderelim
      request.fields['includes'] = jsonEncode(includes);
    }

    if (languages != null) {
      request.fields['languages'] = jsonEncode(languages);
    }

    if (tags != null) {
      request.fields['tags'] = jsonEncode(tags);
    }

    if (schedule != null) {
      request.fields['schedule'] = jsonEncode(schedule);
    }

    // Adım 6: İsteği gönder ve yanıtı işle
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
      } else {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['experience'] != null) {}
        } catch (e) {}
      }

      return _apiService.processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Deneyimi güncelle
  Future<Map<String, dynamic>> updateExperience({
    required String id,
    String? title,
    String? subtitle,
    String? description,
    int? price,
    String? currency,
    String? duration,
    String? location,
    Map<String, dynamic>? coordinates,
    String? category,
    int? maxGuests,
    List<String>? includes,
    List<String>? languages,
    List<String>? tags,
    List<Map<String, dynamic>>? schedule,
    bool? isActive,
  }) async {
    return await _apiService.put('/experiences/$id', {
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (duration != null) 'duration': duration,
      if (location != null) 'location': location,
      if (coordinates != null) 'coordinates': coordinates,
      if (category != null) 'category': category,
      if (maxGuests != null) 'maxGuests': maxGuests,
      if (includes != null) 'includes': includes,
      if (languages != null) 'languages': languages,
      if (tags != null) 'tags': tags,
      if (schedule != null) 'schedule': schedule,
      if (isActive != null) 'isActive': isActive,
    });
  }

  // Deneyim resmi yükle
  Future<Map<String, dynamic>> uploadExperienceImage(
      String id, File image) async {
    return await _apiService.uploadFile(
      '/experiences/$id/image',
      'experienceImage',
      image,
    );
  }

  // Deneyim programı ekle
  Future<Map<String, dynamic>> addScheduleTime({
    required String id,
    required String date,
    required String startTime,
    required String endTime,
    int? maxGuests,
  }) async {
    return await _apiService.post('/experiences/$id/schedule', {
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      if (maxGuests != null) 'maxGuests': maxGuests,
    });
  }

  // Deneyim programını kaldır
  Future<Map<String, dynamic>> removeScheduleTime(
      String id, String scheduleId) async {
    return await _apiService.delete('/experiences/$id/schedule/$scheduleId');
  }

  // Deneyimi sil
  Future<Map<String, dynamic>> deleteExperience(String id) async {
    return await _apiService.delete('/experiences/$id');
  }
}
