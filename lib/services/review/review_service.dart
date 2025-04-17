import 'package:estate/services/base/api_service.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  // Tüm yorumları getir
  Future<Map<String, dynamic>> getAllReviews({
    String? type,
    String? itemId,
    int page = 1,
    int limit = 10,
  }) async {
    String query = '/reviews?page=$page&limit=$limit';
    if (type != null) query += '&type=$type';
    if (itemId != null) query += '&itemId=$itemId';

    return await _apiService.get(query);
  }

  // Yorumu ID ile getir
  Future<Map<String, dynamic>> getReviewById(String id) async {
    return await _apiService.get('/reviews/$id');
  }

  // Mülk için yorum yap
  Future<Map<String, dynamic>> createPropertyReview({
    required String propertyId,
    required int rating,
    required String comment,
    String? bookingId,
  }) async {
    return await _apiService.post('/reviews/property/$propertyId', {
      'rating': rating,
      'comment': comment,
      if (bookingId != null) 'bookingId': bookingId,
    });
  }

  // Deneyim için yorum yap
  Future<Map<String, dynamic>> createExperienceReview({
    required String experienceId,
    required int rating,
    required String comment,
    String? bookingId,
  }) async {
    return await _apiService.post('/reviews/experience/$experienceId', {
      'rating': rating,
      'comment': comment,
      if (bookingId != null) 'bookingId': bookingId,
    });
  }

  // Ev sahibi için yorum yap
  Future<Map<String, dynamic>> createHostReview({
    required String hostId,
    required int rating,
    required String comment,
    String? bookingId,
  }) async {
    return await _apiService.post('/reviews/host/$hostId', {
      'rating': rating,
      'comment': comment,
      if (bookingId != null) 'bookingId': bookingId,
    });
  }

  // Misafir için yorum yap (ev sahibi)
  Future<Map<String, dynamic>> createGuestReview({
    required String guestId,
    required int rating,
    required String comment,
    String? bookingId,
  }) async {
    return await _apiService.post('/reviews/guest/$guestId', {
      'rating': rating,
      'comment': comment,
      if (bookingId != null) 'bookingId': bookingId,
    });
  }

  // Yoruma yanıt ver
  Future<Map<String, dynamic>> respondToReview({
    required String reviewId,
    required String comment,
  }) async {
    return await _apiService.post('/reviews/$reviewId/respond', {
      'comment': comment,
    });
  }

  // Yorum görünürlüğünü güncelle (admin)
  Future<Map<String, dynamic>> updateReviewVisibility({
    required String reviewId,
    required bool isPublic,
  }) async {
    return await _apiService.put('/reviews/$reviewId/visibility', {
      'isPublic': isPublic,
    });
  }

  // Yorumu sil
  Future<Map<String, dynamic>> deleteReview(String id) async {
    return await _apiService.delete('/reviews/$id');
  }
}
