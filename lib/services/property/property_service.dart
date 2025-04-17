import 'dart:convert';
import 'dart:io';
import 'package:estate/services/base/api_service.dart';
import 'package:estate/services/exception/api_exception.dart';

class PropertyService {
  final ApiService _apiService = ApiService();

  // Mülkleri getir
  Future<List<dynamic>> getProperties({
    String? location,
    String? propertyType,
    int? minPrice,
    int? maxPrice,
    int? minGuests,
    int? maxResults,
    List<String>? amenities,
  }) async {
    String endpoint = '/properties?';

    if (location != null) endpoint += 'location=$location&';
    if (propertyType != null) endpoint += 'propertyType=$propertyType&';
    if (minPrice != null) endpoint += 'minPrice=$minPrice&';
    if (maxPrice != null) endpoint += 'maxPrice=$maxPrice&';
    if (minGuests != null) endpoint += 'minGuests=$minGuests&';
    if (maxResults != null) endpoint += 'limit=$maxResults&';
    if (amenities != null && amenities.isNotEmpty) {
      endpoint += 'amenities=${amenities.join(',')}&';
    }

    final response = await _apiService.get(endpoint);
    return response['properties'] ?? [];
  }

  // Mülk detaylarını getir
  Future<Map<String, dynamic>> getPropertyById(String propertyId) async {
    return await _apiService.get('/properties/$propertyId');
  }

  // Kullanıcının mülklerini getir
  Future<List<dynamic>> getUserProperties() async {
    final response = await _apiService.get('/properties/user');
    return response['properties'] ?? [];
  }

  // Yeni mülk oluştur
  Future<Map<String, dynamic>> createProperty({
    required String title,
    required String subtitle,
    required String description,
    required int price,
    required String location,
    required String propertyType,
    required int bedroomCount,
    required int bathroomCount,
    required int maxGuests,
    required List<File> images,
    List<String>? amenities,
  }) async {
    if (images.isEmpty) {
      throw ApiException(
          statusCode: 400, message: 'En az bir fotoğraf gereklidir');
    }

    // Önce temel mülk bilgilerini ve ilk resmi yükle
    final fields = {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'price': price.toString(),
      'location': location,
      'propertyType': propertyType,
      'bedroomCount': bedroomCount.toString(),
      'bathroomCount': bathroomCount.toString(),
      'maxGuests': maxGuests.toString(),
      if (amenities != null && amenities.isNotEmpty)
        'amenities': jsonEncode(amenities),
    };

    return await _apiService.uploadMultipleFiles(
      '/properties',
      'propertyImages',
      images,
      fields,
    );
  }

  // Mülkü güncelle
  Future<Map<String, dynamic>> updateProperty({
    required String propertyId,
    String? title,
    String? subtitle,
    String? description,
    int? price,
    String? location,
    String? propertyType,
    int? bedroomCount,
    int? bathroomCount,
    int? maxGuests,
    List<String>? amenities,
  }) async {
    final data = {
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (location != null) 'location': location,
      if (propertyType != null) 'propertyType': propertyType,
      if (bedroomCount != null) 'bedroomCount': bedroomCount,
      if (bathroomCount != null) 'bathroomCount': bathroomCount,
      if (maxGuests != null) 'maxGuests': maxGuests,
      if (amenities != null) 'amenities': amenities,
    };

    return await _apiService.put('/properties/$propertyId', data);
  }

  // Mülk resmini yükle
  Future<Map<String, dynamic>> addPropertyImage(
      String propertyId, File imageFile) async {
    return await _apiService.uploadFile(
      '/properties/$propertyId/images',
      'propertyImage',
      imageFile,
    );
  }

  // Mülk resmini sil
  Future<Map<String, dynamic>> deletePropertyImage(
      String propertyId, String imageId) async {
    return await _apiService.delete('/properties/$propertyId/images/$imageId');
  }

  // Mülkü sil
  Future<Map<String, dynamic>> deleteProperty(String propertyId) async {
    return await _apiService.delete('/properties/$propertyId');
  }
}
