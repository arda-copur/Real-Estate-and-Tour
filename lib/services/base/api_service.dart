import 'dart:convert';
import 'dart:io';
import 'package:estate/services/exception/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  //Emulator url
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Servis singleton yapısı
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Token işlemleri
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Temel HTTP istekleri
  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return processResponse(response);
  }

  // Liste döndüren HTTP isteği
  Future<List<dynamic>> getList(String endpoint) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final dynamic parsed = processResponse(response);

      // Eğer doğrudan bir liste döndüyse
      if (parsed is List) {
        return parsed;
      }

      // Eğer bir map döndüyse ve içerisinde liste varsa
      if (parsed is Map) {
        // Endpoint'ten liste adını çıkarmaya çalış
        String? listKey;
        if (endpoint.contains('properties')) {
          listKey = 'savedProperties';
        } else if (endpoint.contains('experiences')) {
          listKey = 'savedExperiences';
        }

        // Önce bilinen anahtar adını kontrol et
        if (listKey != null && parsed.containsKey(listKey)) {
          final list = parsed[listKey];
          if (list is List) {
            return list;
          }
        }

        // Map'deki ilk liste türündeki değeri bul ve döndür
        for (var key in parsed.keys) {
          final value = parsed[key];
          if (value is List) {
            return value;
          }
        }
      }

      // Hiçbir liste bulunamadıysa boş liste döndür

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return processResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return processResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return processResponse(response);
  }

  // Multipart istek (dosya yükleme)
  Future<Map<String, dynamic>> uploadFile(
      String endpoint, String fieldName, File file,
      [Map<String, String>? fields]) async {
    final token = await getToken();
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    // Token ekle
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Dosya ekle
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    // Ek alanlar ekle
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return processResponse(response);
  }

  // Çoklu dosya yükleme
  Future<Map<String, dynamic>> uploadMultipleFiles(
      String endpoint, String fieldName, List<File> files,
      [Map<String, String>? fields]) async {
    final token = await getToken();
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    // Token ekle
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Dosyaları ekle
    for (var file in files) {
      request.files
          .add(await http.MultipartFile.fromPath(fieldName, file.path));
    }

    // Ek alanlar ekle
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return processResponse(response);
  }

  // Cevap işleme
  dynamic processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};

      try {
        // API yanıtını JSON olarak parse et
        final dynamic parsed = jsonDecode(response.body);
        return parsed;
      } catch (e) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'API yanıtı işlenemedi: $e',
        );
      }
    } else {
      // Hata durumu
      try {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Bir hata oluştu'};
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody['message'] ?? 'Bir hata oluştu',
        );
      } catch (e) {
        // JSON parse hatası durumunda
        throw ApiException(
          statusCode: response.statusCode,
          message: 'API hatası: ${response.body}',
        );
      }
    }
  }
}
