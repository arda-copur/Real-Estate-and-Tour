class Property {
  final String id;
  final List<String> images;
  final String title;
  final String subtitle;
  final String price;
  final bool perNight;
  final double rating;
  final int reviewCount;
  final bool isSuperhost;
  final String location;
  final String hostName;
  final String hostImage;
  final String description;
  final List<String> amenities;
  final List<String> tags;
  bool isFavorite;

  Property({
    required this.id,
    required this.images,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.perNight,
    required this.rating,
    required this.reviewCount,
    required this.isSuperhost,
    required this.location,
    required this.hostName,
    required this.hostImage,
    required this.description,
    required this.amenities,
    this.tags = const [],
    this.isFavorite = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // API'den gelen fiyatı Türk Lirası formatına dönüştür
    String formattedPrice = '';
    if (json['price'] != null) {
      if (json['price'] is int || json['price'] is double) {
        formattedPrice = '₺${json['price']}';
      } else {
        formattedPrice = '₺${json['price'].toString()}';
      }
    } else {
      formattedPrice = '₺0';
    }

    // API'den gelen resimleri uygun formata dönüştür
    List<String> imageUrls = [];
    if (json['images'] != null && json['images'] is List) {
      imageUrls = List<String>.from(json['images'].map((image) {
        // Eğer image tam URL ise olduğu gibi kullan, değilse base URL ekle
        if (image.toString().startsWith('http')) {
          return image.toString();
        } else {
          return 'http://10.0.2.2:5000/${image.startsWith('/') ? image.substring(1) : image}';
        }
      }));
    }

    // Host'un profil resmi için aynı mantık
    String hostImageUrl = '';
    if (json['hostImage'] != null && json['hostImage'].toString().isNotEmpty) {
      if (json['hostImage'].toString().startsWith('http')) {
        hostImageUrl = json['hostImage'].toString();
      } else {
        hostImageUrl =
            'http://10.0.2.2:5000/${json['hostImage'].toString().startsWith('/') ? json['hostImage'].toString().substring(1) : json['hostImage']}';
      }
    } else if (json['host'] != null &&
        json['host'] is Map &&
        json['host']['profileImage'] != null) {
      final profileImage = json['host']['profileImage'].toString();
      if (profileImage.startsWith('http')) {
        hostImageUrl = profileImage;
      } else {
        hostImageUrl =
            'http://10.0.2.2:5000/${profileImage.startsWith('/') ? profileImage.substring(1) : profileImage}';
      }
    }

    // Amenities düzenleme
    List<String> amenities = [];
    if (json['amenities'] != null && json['amenities'] is List) {
      amenities = List<String>.from(json['amenities'].map((amenity) {
        // Tüm türleri string'e çevir ve tırnak işaretlerini temizle
        String cleanAmenity = amenity.toString();

        // Tırnak işaretlerini düzgün şekilde temizle
        if (cleanAmenity.startsWith('"') && cleanAmenity.endsWith('"')) {
          cleanAmenity = cleanAmenity.substring(1, cleanAmenity.length - 1);
        } else if (cleanAmenity.startsWith("'") && cleanAmenity.endsWith("'")) {
          cleanAmenity = cleanAmenity.substring(1, cleanAmenity.length - 1);
        } else if (cleanAmenity.startsWith("[") && cleanAmenity.endsWith("]")) {
          // Liste gibi görünen stringlerde de temizleme yap
          cleanAmenity = cleanAmenity.substring(1, cleanAmenity.length - 1);
        }

        // İkinci seviye tırnak işaretlerini de temizle
        if (cleanAmenity.startsWith('"') && cleanAmenity.endsWith('"')) {
          cleanAmenity = cleanAmenity.substring(1, cleanAmenity.length - 1);
        } else if (cleanAmenity.startsWith("'") && cleanAmenity.endsWith("'")) {
          cleanAmenity = cleanAmenity.substring(1, cleanAmenity.length - 1);
        }

        return cleanAmenity;
      }));
    }

    // Temel özellikleri her zaman amenities'e ekle
    if (json['bedroomCount'] != null) {
      amenities.add('${json['bedroomCount']} Yatak Odası');
    }
    if (json['bathroomCount'] != null) {
      amenities.add('${json['bathroomCount']} Banyo');
    }
    if (json['maxGuests'] != null) {
      amenities.add('${json['maxGuests']} Misafir');
    }

    // Tags düzenleme
    List<String> tags = [];
    if (json['tags'] != null && json['tags'] is List) {
      tags = List<String>.from(json['tags']);
    }

    return Property(
      id: json['_id'] ?? '',
      images: imageUrls,
      title: json['title'] ?? 'İsimsiz Mülk',
      subtitle: json['subtitle'] ?? '',
      price: formattedPrice,
      perNight: json['perNight'] ?? true,
      rating: (json['rating'] is int || json['rating'] is double)
          ? double.parse(json['rating'].toString())
          : 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isSuperhost: json['isSuperhost'] ?? false,
      location: json['location'] ?? '',
      hostName: json['hostName'] ??
          (json['host'] != null && json['host'] is Map
              ? "${json['host']['firstName'] ?? ''} ${json['host']['lastName'] ?? ''}"
              : 'Ev Sahibi'),
      hostImage: hostImageUrl,
      description: json['description'] ?? '',
      amenities: amenities,
      tags: tags,
      isFavorite: json['isSaved'] ?? false,
    );
  }
}
