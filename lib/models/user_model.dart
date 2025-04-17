import 'package:estate/services/base/api_service.dart';



class User {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final String? _profileImage;
  final List<String> savedProperties;
  final List<String> savedExperiences;
  final int? age;
  final String? city;
  final String? bio;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    String? profileImage,
    required this.savedProperties,
    required this.savedExperiences,
    this.age,
    this.city,
    this.bio,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  }) : _profileImage = profileImage;

  String get profileImage {
    if (_profileImage == null || _profileImage.isEmpty) {
      return '${ApiService.baseUrl.replaceFirst('/api', '')}/uploads/defaults/default-profile.jpg';
    }
    if (_profileImage.startsWith('http')) return _profileImage;

    return '${ApiService.baseUrl.replaceFirst('/api', '')}/${_profileImage.startsWith('/') ? _profileImage.substring(1) : _profileImage}';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    String userId = '';
    if (json.containsKey('_id') && json['_id'] != null) {
      userId = json['_id'].toString();
    } else if (json.containsKey('id') && json['id'] != null) {
      userId = json['id'].toString();
    }

    return User(
      id: userId,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'user',
      profileImage: json['profileImage'],
      savedProperties: List<String>.from(json['savedProperties'] ?? []),
      savedExperiences: List<String>.from(json['savedExperiences'] ?? []),
      age: json['age'],
      city: json['city'],
      bio: json['bio'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'profileImage': _profileImage,
      'savedProperties': savedProperties,
      'savedExperiences': savedExperiences,
      'age': age,
      'city': city,
      'bio': bio,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  bool get isAdmin => role == 'admin';

  bool get isHost => role == 'host' || isAdmin;

  String get formattedCreatedAt {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];

    return '${months[createdAt.month - 1]} ${createdAt.year}\'den';
  }
}

class UserCredentials {
  final User user;
  final String token;

  UserCredentials({
    required this.user,
    required this.token,
  });

  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    return UserCredentials(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}
