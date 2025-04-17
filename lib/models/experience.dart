class Experience {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final String category;
  final String price;
  final double rating;
  final int reviewCount;
  final String location;
  final String hostName;
  final String hostImage;
  final String description;
  final List<String> included;
  final List<String> tags;
  bool isFavorite;

  Experience({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.hostName,
    required this.hostImage,
    required this.description,
    required this.included,
    this.tags = const [],
    this.isFavorite = false,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
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

    // Deneyim resmi için URL düzenleme
    String imageUrl = '';
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      if (json['image'].toString().startsWith('http')) {
        imageUrl = json['image'].toString();
      } else {
        imageUrl =
            'http://10.0.2.2:5000/${json['image'].toString().startsWith('/') ? json['image'].toString().substring(1) : json['image']}';
      }
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

    // Dahil olanlar listesi
    List<String> includes = [];
    if (json['included'] != null && json['included'] is List) {
      includes = List<String>.from(json['included'].map((item) {
        // Tüm türleri string'e çevir ve tırnak işaretlerini temizle
        String cleanItem = item.toString();

        // Tırnak işaretlerini düzgün şekilde temizle
        if (cleanItem.startsWith('"') && cleanItem.endsWith('"')) {
          cleanItem = cleanItem.substring(1, cleanItem.length - 1);
        } else if (cleanItem.startsWith("'") && cleanItem.endsWith("'")) {
          cleanItem = cleanItem.substring(1, cleanItem.length - 1);
        } else if (cleanItem.startsWith("[") && cleanItem.endsWith("]")) {
          // Liste gibi görünen stringlerde de temizleme yap
          cleanItem = cleanItem.substring(1, cleanItem.length - 1);
        }

        // İkinci seviye tırnak işaretlerini de temizle
        if (cleanItem.startsWith('"') && cleanItem.endsWith('"')) {
          cleanItem = cleanItem.substring(1, cleanItem.length - 1);
        } else if (cleanItem.startsWith("'") && cleanItem.endsWith("'")) {
          cleanItem = cleanItem.substring(1, cleanItem.length - 1);
        }

        return cleanItem;
      }));
    }

    // Tags düzenleme
    List<String> tags = [];
    if (json['tags'] != null && json['tags'] is List) {
      tags = List<String>.from(json['tags']);
    }

    return Experience(
      id: json['_id'] ?? '',
      image: imageUrl,
      title: json['title'] ?? 'İsimsiz Deneyim',
      subtitle: json['subtitle'] ?? 'Organizator ekstra bir not eklememiş',
      category: json['category'] ?? '',
      price: formattedPrice,
      rating: (json['rating'] is int || json['rating'] is double)
          ? double.parse(json['rating'].toString())
          : 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      location: json['location'] ?? '',
      hostName: json['hostName'] ??
          (json['host'] != null && json['host'] is Map
              ? "${json['host']['firstName'] ?? ''} ${json['host']['lastName'] ?? ''}"
              : 'Organizatör'),
      hostImage: hostImageUrl,
      description: json['description'] ?? '',
      included: includes,
      tags: tags,
      isFavorite: json['isSaved'] ?? false,
    );
  }
}
