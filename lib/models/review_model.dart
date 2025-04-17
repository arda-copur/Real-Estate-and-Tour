class Review {
  final String id;
  final String user;
  final String reviewType;
  final String? property;
  final String? experience;
  final String? host;
  final String? guest;
  final String? booking;
  final int rating;
  final String comment;
  final ReviewResponse? response;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populate fields
  final Map<String, dynamic>? userData;

  Review({
    required this.id,
    required this.user,
    required this.reviewType,
    this.property,
    this.experience,
    this.host,
    this.guest,
    this.booking,
    required this.rating,
    required this.comment,
    this.response,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.userData,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      user: json['user']['_id'] ?? json['user'],
      reviewType: json['reviewType'],
      property: json['property'],
      experience: json['experience'],
      host: json['host'],
      guest: json['guest'],
      booking: json['booking'],
      rating: json['rating'],
      comment: json['comment'],
      response: json['response'] != null
          ? ReviewResponse.fromJson(json['response'])
          : null,
      isPublic: json['isPublic'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userData: json['user'] is Map ? json['user'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'reviewType': reviewType,
      'property': property,
      'experience': experience,
      'host': host,
      'guest': guest,
      'booking': booking,
      'rating': rating,
      'comment': comment,
      'response': response?.toJson(),
      'isPublic': isPublic,
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

  String getUserImage() {
    if (userData != null && userData!['profileImage'] != null) {
      return userData!['profileImage'];
    }
    return 'assets/images/default-profile.jpg';
  }

  String get reviewTypeLabel {
    switch (reviewType) {
      case 'property':
        return 'Mülk';
      case 'experience':
        return 'Deneyim';
      case 'host':
        return 'Ev Sahibi';
      case 'guest':
        return 'Misafir';
      default:
        return reviewType;
    }
  }

  String get formattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    return '$day.$month.$year';
  }
}

class ReviewResponse {
  final String comment;
  final DateTime date;

  ReviewResponse({
    required this.comment,
    required this.date,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      comment: json['comment'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day.$month.$year';
  }
}
