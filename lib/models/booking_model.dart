import 'package:estate/services/base/api_service.dart';

class Booking {
  final String id;
  final String userId;
  final String? propertyId;
  final String? experienceId;
  final String bookingType;
  final DateTime startDate;
  final DateTime? endDate;
  final TimeSlot? timeSlot;
  final int guestCount;
  final double totalPrice;
  final String currency;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? notes;
  final String? cancellationReason;
  final DateTime? cancellationDate;
  final bool hasReview;
  final DateTime createdAt;
  final DateTime updatedAt;

  // İlişkili veriler
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? property;
  final Map<String, dynamic>? experience;

  Booking({
    required this.id,
    required this.userId,
    this.propertyId,
    this.experienceId,
    required this.bookingType,
    required this.startDate,
    this.endDate,
    this.timeSlot,
    required this.guestCount,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.notes,
    this.cancellationReason,
    this.cancellationDate,
    required this.hasReview,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.property,
    this.experience,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    String bookingId = '';
    if (json.containsKey('_id') && json['_id'] != null) {
      bookingId = json['_id'].toString();
    } else if (json.containsKey('id') && json['id'] != null) {
      bookingId = json['id'].toString();
    }

    String userId = '';
    if (json.containsKey('user') && json['user'] != null) {
      if (json['user'] is Map) {
        userId = json['user']['_id'] ?? json['user']['id'] ?? '';
      } else {
        userId = json['user'].toString();
      }
    }

    return Booking(
      id: bookingId,
      userId: userId,
      propertyId: json['property'] is Map ? json['property']['_id'] : json['property'],
      experienceId: json['experience'] is Map ? json['experience']['_id'] : json['experience'],
      bookingType: json['bookingType'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      timeSlot: json['timeSlot'] != null ? TimeSlot.fromJson(json['timeSlot']) : null,
      guestCount: json['guestCount'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? '₺',
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      cancellationDate: json['cancellationDate'] != null
          ? DateTime.parse(json['cancellationDate'])
          : null,
      hasReview: json['hasReview'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: json['user'] is Map ? json['user'] : null,
      property: json['property'] is Map ? json['property'] : null,
      experience: json['experience'] is Map ? json['experience'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'property': propertyId,
      'experience': experienceId,
      'bookingType': bookingType,
      'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate?.toIso8601String(),
      if (timeSlot != null) 'timeSlot': timeSlot?.toJson(),
      'guestCount': guestCount,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': status,
      'paymentStatus': paymentStatus,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (cancellationDate != null) 'cancellationDate': cancellationDate?.toIso8601String(),
      'hasReview': hasReview,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedStartDate {
    return '${startDate.day.toString().padLeft(2, '0')}.${startDate.month.toString().padLeft(2, '0')}.${startDate.year}';
  }

  String get formattedEndDate {
    if (endDate == null) return '';
    return '${endDate!.day.toString().padLeft(2, '0')}.${endDate!.month.toString().padLeft(2, '0')}.${endDate!.year}';
  }

  String get formattedTimeSlot {
    if (timeSlot == null) return '';
    return '${timeSlot!.startTime} - ${timeSlot!.endTime}';
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'confirmed':
        return 'Onaylandı';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Beklemede';
    }
  }

  String get paymentStatusText {
    switch (paymentStatus) {
      case 'pending':
        return 'Beklemede';
      case 'paid':
        return 'Ödendi';
      case 'refunded':
        return 'İade Edildi';
      case 'failed':
        return 'Başarısız';
      default:
        return 'Beklemede';
    }
  }

  String get formattedTotalPrice {
    return '$totalPrice $currency';
  }

  String get itemTitle {
    if (bookingType == 'property' && property != null) {
      return property!['title'] ?? 'Mülk';
    } else if (bookingType == 'experience' && experience != null) {
      return experience!['title'] ?? 'Deneyim';
    }
    return bookingType == 'property' ? 'Mülk' : 'Deneyim';
  }

  String get itemImage {
    if (bookingType == 'property' && property != null && property!['images'] != null) {
      final images = property!['images'];
      if (images is List && images.isNotEmpty) {
        String image = images[0];
        if (!image.startsWith('http')) {
          return '${ApiService.baseUrl.replaceFirst('/api', '')}/${image.startsWith('/') ? image.substring(1) : image}';
        }
        return image;
      }
    } else if (bookingType == 'experience' && experience != null && experience!['image'] != null) {
      String image = experience!['image'];
      if (!image.startsWith('http')) {
        return '${ApiService.baseUrl.replaceFirst('/api', '')}/${image.startsWith('/') ? image.substring(1) : image}';
      }
      return image;
    }
    return '';
  }

  String get itemLocation {
    if (bookingType == 'property' && property != null) {
      return property!['location'] ?? '';
    } else if (bookingType == 'experience' && experience != null) {
      return experience!['location'] ?? '';
    }
    return '';
  }

  String get hostName {
    if (bookingType == 'property' && property != null && property!['host'] != null) {
      final host = property!['host'];
      if (host is Map) {
        return '${host['firstName'] ?? ''} ${host['lastName'] ?? ''}';
      }
    } else if (bookingType == 'experience' && experience != null && experience!['host'] != null) {
      final host = experience!['host'];
      if (host is Map) {
        return '${host['firstName'] ?? ''} ${host['lastName'] ?? ''}';
      }
    }
    return '';
  }

  String get guestName {
    if (user != null) {
      return '${user!['firstName'] ?? ''} ${user!['lastName'] ?? ''}';
    }
    return '';
  }

  String get guestImage {
    if (user != null && user!['profileImage'] != null) {
      String image = user!['profileImage'];
      if (!image.startsWith('http')) {
        return '${ApiService.baseUrl.replaceFirst('/api', '')}/${image.startsWith('/') ? image.substring(1) : image}';
      }
      return image;
    }
    return '';
  }

  String get hostId {
    if (bookingType == 'property' && property != null && property!['host'] != null) {
      final host = property!['host'];
      if (host is Map) {
        return host['_id'] ?? host['id'] ?? '';
      } else {
        return host.toString();
      }
    } else if (bookingType == 'experience' && experience != null && experience!['host'] != null) {
      final host = experience!['host'];
      if (host is Map) {
        return host['_id'] ?? host['id'] ?? '';
      } else {
        return host.toString();
      }
    }
    return '';
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;

  TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
