class Booking {
  final String id;
  final String user;
  final String bookingType;
  final String? property;
  final String? experience;
  final DateTime startDate;
  final DateTime endDate;
  final int guests;
  final int totalPrice;
  final String currency;
  final String status;
  final String paymentStatus;
  final bool hasReview;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? propertyData;
  final Map<String, dynamic>? experienceData;

  Booking({
    required this.id,
    required this.user,
    required this.bookingType,
    this.property,
    this.experience,
    required this.startDate,
    required this.endDate,
    required this.guests,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.hasReview,
    required this.createdAt,
    required this.updatedAt,
    this.userData,
    this.propertyData,
    this.experienceData,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      user: json['user']['_id'] ?? json['user'],
      bookingType: json['bookingType'],
      property:
          json['property'] is Map ? json['property']['_id'] : json['property'],
      experience: json['experience'] is Map
          ? json['experience']['_id']
          : json['experience'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      guests: json['guests'],
      totalPrice: json['totalPrice'],
      currency: json['currency'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      hasReview: json['hasReview'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userData: json['user'] is Map ? json['user'] : null,
      propertyData: json['property'] is Map ? json['property'] : null,
      experienceData: json['experience'] is Map ? json['experience'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'bookingType': bookingType,
      'property': property,
      'experience': experience,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'guests': guests,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': status,
      'paymentStatus': paymentStatus,
      'hasReview': hasReview,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String getUserName() {
    if (userData != null) {
      return '${userData!['firstName']} ${userData!['lastName']}';
    }
    return 'Kullanıcı';
  }

  String getPropertyTitle() {
    if (propertyData != null) {
      return propertyData!['title'];
    }
    return 'Mülk';
  }

  String getExperienceTitle() {
    if (experienceData != null) {
      return experienceData!['title'];
    }
    return 'Deneyim';
  }

  String getTitle() {
    if (bookingType == 'property') {
      return getPropertyTitle();
    } else {
      return getExperienceTitle();
    }
  }

  String get formattedStartDate {
    final day = startDate.day.toString().padLeft(2, '0');
    final month = startDate.month.toString().padLeft(2, '0');
    final year = startDate.year;
    return '$day.$month.$year';
  }

  String get formattedEndDate {
    final day = endDate.day.toString().padLeft(2, '0');
    final month = endDate.month.toString().padLeft(2, '0');
    final year = endDate.year;
    return '$day.$month.$year';
  }

  String get formattedDate {
    return '$formattedStartDate - $formattedEndDate';
  }

  String get formattedTotalPrice => '$currency $totalPrice';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'confirmed':
        return 'Onaylandı';
      case 'canceled':
        return 'İptal Edildi';
      case 'completed':
        return 'Tamamlandı';
      default:
        return status;
    }
  }

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'pending':
        return 'Ödeme Beklemede';
      case 'paid':
        return 'Ödenmiş';
      case 'refunded':
        return 'İade Edilmiş';
      default:
        return paymentStatus;
    }
  }
}
