import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../models/experience.dart';
import '../../models/destination.dart';
import '../../models/help_category.dart';
import '../../models/support_ticket.dart';

class DataService extends ChangeNotifier {
  //Başlangıçta kullanılan statik veriler
  static final DataService _instance = DataService._internal();

  factory DataService() {
    return _instance;
  }

  DataService._internal();

  List<Property> _properties = [];
  List<Experience> _experiences = [];
  List<Destination> _destinations = [];
  List<HelpCategory> _helpCategories = [];
  List<SupportTicket> _supportTickets = [];

  List<Property> get properties => _properties;
  List<Experience> get experiences => _experiences;
  List<Property> get savedProperties =>
      _properties.where((p) => p.isFavorite).toList();
  List<Experience> get savedExperiences =>
      _experiences.where((e) => e.isFavorite).toList();

  void initialize() {
    _initializeProperties();
    _initializeExperiences();
    _initializeDestinations();
    _initializeHelpCategories();
    _initializeSupportTickets();
  }

  void _initializeProperties() {
    _properties = [
      Property(
        id: '1',
        images: [
          'assets/images/property1.jpg',
          'assets/images/property1_2.jpg',
          'assets/images/property1_3.jpg',
        ],
        title: 'Miamo - Imerovigli\'de Muhteşem Manzara',
        subtitle: 'BÜTÜN EV · 1 YATAK',
        price: '₺168',
        perNight: true,
        rating: 4.9,
        reviewCount: 174,
        isSuperhost: true,
        location: 'Imerovigli, Yunanistan',
        hostName: 'Marco',
        hostImage: 'assets/images/host.jpg',
        description:
            'Imerovigli\'de bulunan bu muhteşem ev, Ege Denizi\'nin panoramik manzarasını sunuyor. Geleneksel Yunan mimarisi ile modern konforu bir araya getiren bu ev, unutulmaz bir tatil deneyimi yaşamanızı sağlayacak.',
        amenities: ['3 misafir', '1 yatak odası', '2 yatak', '1 banyo'],
        tags: ['deniz manzarası', 'yunanistan', 'imerovigli', 'ada', 'tatil'],
      ),
      Property(
        id: '2',
        images: [
          'assets/images/property2.jpg',
          'assets/images/property2_2.jpg',
          'assets/images/property2_3.jpg',
        ],
        title: '**MERKEZ** Sanatçı Evi',
        subtitle: 'ÖZEL ODA · 1 YATAK ODASI',
        price: '₺98',
        perNight: true,
        rating: 4.7,
        reviewCount: 416,
        isSuperhost: false,
        location: 'Camden, Londra',
        hostName: 'Tessa',
        hostImage: 'assets/images/host.jpg',
        description:
            'Londra\'yı en iyi şekilde deneyimlemek istiyorsanız Camden\'a gelin. Bu bölge şehrin en canlı ve kültürel açıdan zengin bölgelerinden biridir. Evim Camden Town metro istasyonuna sadece 5 dakikalık yürüme mesafesindedir ve şehir merkezine kolay ulaşım sağlar.',
        amenities: ['3 misafir', '1 yatak odası', '2 yatak', '1 ortak banyo'],
        tags: ['londra', 'camden', 'sanatçı', 'merkez', 'şehir'],
      ),
      Property(
        id: '3',
        images: [
          'assets/images/property2.jpg',
          'assets/images/property3_2.jpg',
          'assets/images/property3_3.jpg',
        ],
        title: 'Modern Daire - Şehir Merkezi',
        subtitle: 'BÜTÜN DAİRE · 3 YATAK',
        price: '₺210',
        perNight: true,
        rating: 4.7,
        reviewCount: 132,
        isSuperhost: true,
        location: 'İstanbul, Türkiye',
        hostName: 'Jacob',
        hostImage: 'assets/images/host.jpg',
        description:
            'İstanbul\'un kalbinde yer alan bu modern daire, şehrin tüm önemli noktalarına yakın konumdadır. Tamamen yenilenmiş ve modern mobilyalarla döşenmiş bu daire, konforlu bir konaklama deneyimi sunuyor.',
        amenities: ['6 misafir', '3 yatak odası', '4 yatak', '2 banyo'],
        tags: ['istanbul', 'şehir merkezi', 'modern', 'daire', 'türkiye'],
      ),
      Property(
        id: '4',
        images: [
          'assets/images/property4.jpg',
          'assets/images/property1_2.jpg',
          'assets/images/property1_3.jpg',
        ],
        title: 'Deniz Manzaralı Villa',
        subtitle: 'BÜTÜN VİLLA · 4 YATAK',
        price: '₺350',
        perNight: true,
        rating: 4.8,
        reviewCount: 98,
        isSuperhost: true,
        location: 'Bodrum, Türkiye',
        hostName: 'Mehmet',
        hostImage: 'assets/images/host.jpg',
        description:
            'Bodrum\'un muhteşem manzarasına sahip bu villa, özel havuzu ve geniş terasıyla unutulmaz bir tatil deneyimi sunuyor. Denize yürüme mesafesinde olan villa, tam donanımlı mutfağı ve lüks iç mekanlarıyla konforlu bir konaklama sağlıyor.',
        amenities: ['8 misafir', '4 yatak odası', '5 yatak', '3 banyo'],
        tags: ['bodrum', 'deniz manzarası', 'villa', 'havuz', 'lüks'],
      ),
    ];
  }

  void _initializeExperiences() {
    _experiences = [
      Experience(
        id: '1',
        image: 'assets/images/experience3.jpg',
        title: 'Paris\'in En İyi Saklı Sırları Turu',
        subtitle: 'Paris Sokakları',
        category: 'TARİH YÜRÜYÜŞÜ · PARİS',
        price: '€83',
        rating: 4.9,
        reviewCount: 232,
        location: 'Paris, Fransa',
        hostName: 'Jean',
        hostImage: 'assets/images/host.jpg',
        description:
            'Paris\'in turistik yerlerinden uzak, yerel halkın bildiği gizli mekanları keşfedin. Bu turda, tarihi kafeler, gizli bahçeler ve yerel sanat galerilerini ziyaret edeceksiniz.',
        included: [
          '3 saatlik yürüyüş turu',
          'Yerel bir kafede içecek',
          'Profesyonel rehber'
        ],
        tags: ['paris', 'tarih', 'yürüyüş', 'tur', 'fransa', 'gizli'],
      ),
      Experience(
        id: '2',
        image: 'assets/images/experience2.jpg',
        title: 'Sessiz Disko Plaj Yogası',
        subtitle: 'Yoga',
        category: 'YOGA · SAN FRANCISCO',
        price: '€49',
        rating: 4.8,
        reviewCount: 242,
        location: 'San Francisco, ABD',
        hostName: 'Sarah',
        hostImage: 'assets/images/host.jpg',
        description:
            'Güneşin doğuşuyla birlikte plajda yoga yapın ve kulaklıklarınızdan dinlediğiniz müzikle meditasyon yapın. Bu benzersiz deneyim, zihinsel ve fiziksel dengeyi sağlamanıza yardımcı olacak.',
        included: [
          '90 dakikalık yoga seansı',
          'Kulaklık ve müzik',
          'Yoga matı',
          'Taze meyve suyu'
        ],
        tags: [
          'yoga',
          'plaj',
          'san francisco',
          'meditasyon',
          'disko',
          'sessiz'
        ],
      ),
      Experience(
        id: '3',
        image: 'assets/images/experience3.jpg',
        title: 'Lezzet Evi Yemek Kursu',
        subtitle: 'Yemek tarifleri ve sunum',
        category: 'YEMEK · ROMA',
        price: '€65',
        rating: 4.7,
        reviewCount: 189,
        location: 'Roma, İtalya',
        hostName: 'Maria',
        hostImage: 'assets/images/host.jpg',
        description:
            'İtalyan mutfağının sırlarını öğrenin! Bu kursta, geleneksel İtalyan makarnası, pizza ve tiramisu yapmayı öğreneceksiniz. Tüm malzemeler ve ekipmanlar dahildir.',
        included: [
          '3 saatlik yemek kursu',
          'Tüm malzemeler',
          'Şarap tadımı',
          'Yemek tarifleri'
        ],
        tags: [
          'yemek',
          'kurs',
          'roma',
          'italya',
          'makarna',
          'pizza',
          'tiramisu'
        ],
      ),
      Experience(
        id: '4',
        image: 'assets/images/experience4.jpg',
        title: 'Orman Yürüyüşü ve Fotoğrafçılık',
        subtitle: 'Ormanda vakit geçirme',
        category: 'DOĞA · VANCOUVER',
        price: '€55',
        rating: 4.9,
        reviewCount: 156,
        location: 'Vancouver, Kanada',
        hostName: 'Michael',
        hostImage: 'assets/images/host.jpg',
        description:
            'Vancouver\'ın muhteşem ormanlarında profesyonel bir fotoğrafçı eşliğinde yürüyüş yapın. Doğa fotoğrafçılığının temel tekniklerini öğrenin ve unutulmaz kareler yakalayın.',
        included: [
          '4 saatlik yürüyüş',
          'Fotoğrafçılık dersi',
          'Atıştırmalıklar ve su',
          'Fotoğraf düzenleme ipuçları'
        ],
        tags: [
          'doğa',
          'fotoğrafçılık',
          'vancouver',
          'orman',
          'yürüyüş',
          'kanada'
        ],
      ),
    ];
  }

  void _initializeDestinations() {
    _destinations = [
      Destination(
        id: '1',
        name: 'İstanbul',
        image: 'assets/images/property1.jpg',
        description:
            'Avrupa ve Asya\'yı birleştiren, tarihi ve modern yapıların bir arada bulunduğu eşsiz şehir.',
        popularAttractions: [
          'Ayasofya',
          'Topkapı Sarayı',
          'Kapalıçarşı',
          'Boğaz'
        ],
      ),
      Destination(
        id: '2',
        name: 'Antalya',
        image: 'assets/images/property2.jpg',
        description:
            'Turkuaz renkli denizi, altın sarısı kumsalları ve tarihi kalıntılarıyla Türkiye\'nin turizm cenneti.',
        popularAttractions: [
          'Kaleiçi',
          'Düden Şelalesi',
          'Aspendos',
          'Konyaaltı Plajı'
        ],
      ),
      Destination(
        id: '3',
        name: 'Bodrum',
        image: 'assets/images/property2.jpg',
        description:
            'Beyaz badanalı evleri, masmavi denizi ve canlı gece hayatıyla ünlü tatil beldesi.',
        popularAttractions: [
          'Bodrum Kalesi',
          'Halikarnas Mozolesi',
          'Gümbet Plajı',
          'Bitez Koyu'
        ],
      ),
      Destination(
        id: '4',
        name: 'Kapadokya',
        image: 'assets/images/property4.jpg',
        description:
            'Peri bacaları, yeraltı şehirleri ve sıcak hava balonlarıyla masalsı bir deneyim sunan bölge.',
        popularAttractions: [
          'Göreme Açık Hava Müzesi',
          'Uçhisar Kalesi',
          'Derinkuyu Yeraltı Şehri',
          'Balon Turu'
        ],
      ),
      Destination(
        id: '5',
        name: 'Fethiye',
        image: 'assets/images/property1_2.jpg',
        description:
            'Turkuaz koyları, lagünleri ve doğal güzellikleriyle Akdeniz\'in incisi.',
        popularAttractions: [
          'Ölüdeniz',
          'Kelebekler Vadisi',
          'Saklıkent Kanyonu',
          'Kayaköy'
        ],
      ),
      Destination(
        id: '6',
        name: 'İzmir',
        image: 'assets/images/property2_2.jpg',
        description:
            'Modern yapısı, körfezi ve zengin kültürüyle Ege\'nin incisi.',
        popularAttractions: [
          'Kordon',
          'Saat Kulesi',
          'Kemeraltı Çarşısı',
          'Efes Antik Kenti'
        ],
      ),
    ];
  }

  void _initializeHelpCategories() {
    _helpCategories = [
      HelpCategory(
        id: '1',
        title: 'Rezervasyon ve Ödemeler',
        icon: Icons.calendar_today,
        articles: [
          'Rezervasyon nasıl yapılır?',
          'Ödeme seçenekleri nelerdir?',
          'Rezervasyon iptal politikası',
          'İade işlemleri nasıl yapılır?',
        ],
      ),
      HelpCategory(
        id: '2',
        title: 'Hesap Yönetimi',
        icon: Icons.person,
        articles: [
          'Profil bilgilerimi nasıl güncellerim?',
          'Şifremi unuttum',
          'Hesabımı nasıl silerim?',
          'Güvenlik ayarları',
        ],
      ),
      HelpCategory(
        id: '3',
        title: 'Ev Sahipliği',
        icon: Icons.home,
        articles: [
          'Nasıl ev sahibi olurum?',
          'Fiyatlandırma stratejileri',
          'Ev sahibi güvenlik önlemleri',
          'Misafir iletişimi',
        ],
      ),
      HelpCategory(
        id: '4',
        title: 'Deneyim Düzenleme',
        icon: Icons.explore,
        articles: [
          'Deneyim oluşturma adımları',
          'Deneyim fiyatlandırma',
          'Deneyim güvenlik kuralları',
          'Deneyim pazarlama ipuçları',
        ],
      ),
    ];
  }

  void _initializeSupportTickets() {
    _supportTickets = [
      SupportTicket(
        id: '1',
        subject: 'Rezervasyon İptali',
        description:
            'Rezervasyonumu iptal etmek istiyorum ancak tam iade alamıyorum.',
        status: TicketStatus.open,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        messages: [
          TicketMessage(
            sender: 'Ahmet Yılmaz',
            message:
                'Rezervasyonumu iptal etmek istiyorum ancak tam iade alamıyorum.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isUser: true,
          ),
          TicketMessage(
            sender: 'Destek Ekibi',
            message:
                'Merhaba Ahmet, rezervasyon iptal politikamıza göre, rezervasyonunuzu 48 saat öncesinde iptal ederseniz tam iade alabilirsiniz. Rezervasyon detaylarınızı kontrol edip size yardımcı olacağız.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isUser: false,
          ),
        ],
      ),
      SupportTicket(
        id: '2',
        subject: 'Ev Sahibi İletişim Sorunu',
        description: 'Ev sahibine mesaj gönderdim ancak cevap alamıyorum.',
        status: TicketStatus.closed,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        messages: [
          TicketMessage(
            sender: 'Ahmet Yılmaz',
            message: 'Ev sahibine mesaj gönderdim ancak cevap alamıyorum.',
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            isUser: true,
          ),
          TicketMessage(
            sender: 'Destek Ekibi',
            message:
                'Merhaba Ahmet, ev sahibiyle iletişime geçtik. Şu anda seyahatte olduğunu ve internet erişiminin kısıtlı olduğunu belirtti. En kısa sürede size dönüş yapacağını iletti.',
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
            isUser: false,
          ),
          TicketMessage(
            sender: 'Ahmet Yılmaz',
            message: 'Teşekkür ederim, ev sahibinden mesaj aldım.',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            isUser: true,
          ),
        ],
      ),
    ];
  }

  void togglePropertyFavorite(String id) {
    final index = _properties.indexWhere((p) => p.id == id);
    if (index != -1) {
      _properties[index].isFavorite = !_properties[index].isFavorite;
      notifyListeners();
    }
  }

  void toggleExperienceFavorite(String id) {
    final index = _experiences.indexWhere((e) => e.id == id);
    if (index != -1) {
      _experiences[index].isFavorite = !_experiences[index].isFavorite;
      notifyListeners();
    }
  }

  List<Property> searchProperties(String query) {
    if (query.isEmpty) {
      return _properties;
    }

    // Geliştirilmiş arama algoritması
    final lowercaseQuery = query.toLowerCase();
    return _properties
        .where((p) =>
            p.title.toLowerCase().contains(lowercaseQuery) ||
            p.location.toLowerCase().contains(lowercaseQuery) ||
            p.description.toLowerCase().contains(lowercaseQuery) ||
            p.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  List<Experience> searchExperiences(String query) {
    if (query.isEmpty) {
      return _experiences;
    }

    // Geliştirilmiş arama algoritması
    final lowercaseQuery = query.toLowerCase();
    return _experiences
        .where((e) =>
            e.title.toLowerCase().contains(lowercaseQuery) ||
            e.location.toLowerCase().contains(lowercaseQuery) ||
            e.category.toLowerCase().contains(lowercaseQuery) ||
            e.description.toLowerCase().contains(lowercaseQuery) ||
            e.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  List<Property> filterProperties({
    String? location,
    String? priceRange,
    bool? superhost,
  }) {
    List<Property> filtered = List.from(_properties);

    if (location != null && location.isNotEmpty) {
      filtered = filtered
          .where(
              (p) => p.location.toLowerCase().contains(location.toLowerCase()))
          .toList();
    }

    if (priceRange != null) {
      // Örnek: "100-200" formatında
      final parts = priceRange.split('-');
      if (parts.length == 2) {
        final min = int.tryParse(parts[0]) ?? 0;
        final max = int.tryParse(parts[1]) ?? 1000;

        filtered = filtered.where((p) {
          final price =
              int.tryParse(p.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return price >= min && price <= max;
        }).toList();
      }
    }

    if (superhost == true) {
      filtered = filtered.where((p) => p.isSuperhost).toList();
    }

    return filtered;
  }

  List<Destination> getDestinations() {
    return _destinations;
  }

  List<HelpCategory> getHelpCategories() {
    return _helpCategories;
  }

  List<SupportTicket> getSupportTickets() {
    return _supportTickets;
  }

  void addSupportTicket(SupportTicket ticket) {
    _supportTickets.add(ticket);
    notifyListeners();
  }

  void addTicketMessage(String ticketId, TicketMessage message) {
    final index = _supportTickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      _supportTickets[index].messages.add(message);
      notifyListeners();
    }
  }
}
