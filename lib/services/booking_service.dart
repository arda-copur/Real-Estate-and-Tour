import 'package:estate/services/base/api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  // Tüm rezervasyonları getir (Admin)
  Future<Map<String, dynamic>> getAllBookings({
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiService.get('/bookings?page=$page&limit=$limit');
  }

  // Kullanıcının kendi rezervasyonlarını getir
  Future<List<dynamic>> getMyBookings() async {
    try {
      // ApiService'in getList() metodunu kullanarak doğrudan liste alalım
      final response = await _apiService.getList('/bookings/my-bookings');
      return response;
    } catch (e) {
      print('Kullanıcı rezervasyonları hatası: $e');
      return []; // Hata durumunda boş liste dön
    }
  }

  // Ev sahibinin rezervasyonlarını getir
  Future<List<dynamic>> getHostBookings() async {
    try {
      // ApiService'in getList() metodunu kullanarak doğrudan liste alalım
      final response = await _apiService.getList('/bookings/host-bookings');
      return response;
    } catch (e) {
      print('Ev sahibi rezervasyonları hatası: $e');
      return []; // Hata durumunda boş liste dön
    }
  }

  // Rezervasyon detaylarını getir
  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    return await _apiService.get('/bookings/$bookingId');
  }

  // Mülk için rezervasyon oluştur
  Future<Map<String, dynamic>> createPropertyBooking({
    required String propertyId,
    required String startDate,
    required String endDate,
    required int guestCount,
    String? notes,
  }) async {
    return await _apiService.post('/bookings', {
      'bookingType': 'property',
      'propertyId': propertyId,
      'startDate': startDate,
      'endDate': endDate,
      'guestCount': guestCount,
      if (notes != null) 'notes': notes,
    });
  }

  // Deneyim için rezervasyon oluştur
  Future<Map<String, dynamic>> createExperienceBooking({
    required String experienceId,
    required String startDate,
    required Map<String, String> timeSlot,
    required int guestCount,
    String? notes,
  }) async {
    return await _apiService.post('/bookings', {
      'bookingType': 'experience',
      'experienceId': experienceId,
      'startDate': startDate,
      'timeSlot': timeSlot,
      'guestCount': guestCount,
      if (notes != null) 'notes': notes,
    });
  }

  // Rezervasyon durumunu güncelle (Ev sahibi/admin)
  Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
    String? cancellationReason,
  }) async {
    final data = {'status': status};
    if (status == 'cancelled' && cancellationReason != null) {
      data['cancellationReason'] = cancellationReason;
    }

    return await _apiService.put('/bookings/$bookingId/status', data);
  }

  // Ödeme durumunu güncelle (Admin)
  Future<Map<String, dynamic>> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
    String? paymentMethod,
  }) async {
    final data = {
      'paymentStatus': paymentStatus,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };

    return await _apiService.put('/bookings/$bookingId/payment', data);
  }

  // Rezervasyonu sil (Admin)
  Future<Map<String, dynamic>> deleteBooking(String bookingId) async {
    return await _apiService.delete('/bookings/$bookingId');
  }
}
