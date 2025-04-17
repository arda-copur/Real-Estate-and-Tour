// ignore_for_file: use_build_context_synchronously, empty_catches, unused_local_variable
import 'package:estate/providers/auth_provider.dart';
import 'package:estate/screens/profile/other_user_profile.dart';
import 'package:estate/screens/profile/user_profile_screen.dart';
import 'package:estate/services/exception/api_exception.dart';
import 'package:estate/services/property/property_service.dart';
import 'package:estate/services/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom/image_carousel.dart';
import '../../widgets/profile/host_profile.dart';
import '../../models/property.dart';
import 'package:intl/intl.dart';
import 'package:estate/models/booking_model.dart';
import 'package:estate/services/booking_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final PropertyService _propertyService = PropertyService();
  final UserService _userService = UserService();
  final BookingService _bookingService = BookingService();

  Map<String, dynamic>? _propertyData;
  Property? _property;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;
  bool _isReserved = false;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();

    // Favori durumunu doğrudan kontrol et (API'dan gelen veriye ek olarak)
    // 1 saniye gecikme ekliyoruz, ilk yükleme sırasında API istekleri tamamlanması için
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _checkSavedStatus();
        _checkReservationStatus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sayfaya her giriş yapıldığında ve bağımlılıklar değiştiğinde kontrol et
    if (!_isLoading && _property != null) {
      _checkSavedStatus();
    }
  }

  Future<void> _loadPropertyDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Mülk detaylarını yükle
      final propertyData =
          await _propertyService.getPropertyById(widget.propertyId);

      if (propertyData.containsKey('_id')) {}
      if (propertyData.containsKey('id')) {}

      // Eğer kaydedilmiş durumu (isSaved) mülk verilerinde varsa direkt kullan
      // Yoksa ayrıca kontrol et
      bool isSaved = false;

      // API'den gelen isSaved değerini kontrol et
      if (propertyData.containsKey('isSaved')) {
        try {
          if (propertyData['isSaved'] is bool) {
            isSaved = propertyData['isSaved'];
          } else if (propertyData['isSaved'] == 'true') {
            isSaved = true;
          } else if (propertyData['isSaved'] == 'false') {
            isSaved = false;
          }
        } catch (e) {}
      } else {
        // isSaved değeri yoksa, kullanıcının kaydedilmiş mülklerini kontrol et
        try {
          final savedProperties = await _userService.getSavedProperties();

          // API'den dönen yanıtı güvenli bir şekilde işle
          for (var item in savedProperties) {
            try {
              String? itemId = _extractId(item);
              if (itemId == null) continue;

              // Tam karşılaştırma
              if (itemId == widget.propertyId) {
                isSaved = true;
                break;
              }
            } catch (e) {}
          }
        } catch (e) {
          // Favorileri alma hatası - varsayılan false olarak kalsın
        }
      }

      setState(() {
        _propertyData = propertyData;
        _property = Property.fromJson(propertyData);
        _isFavorite = isSaved;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            e is ApiException ? e.message : 'Veri yüklenirken bir hata oluştu';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await _userService.removeSavedProperty(widget.propertyId);
      } else {
        await _userService.saveProperty(widget.propertyId);
      }

      // UI'ı güncelle
      setState(() {
        _isFavorite = !_isFavorite;
        if (_propertyData != null) {
          _propertyData!['isSaved'] = _isFavorite;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? "İlan favorilere eklendi"
              : "İlan favorilerden kaldırıldı"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Hata durumunda gerçek favori durumunu tekrar kontrol et
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException
              ? e.message
              : 'İşlem sırasında bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );

      // Favori durumunu teyit et
      await _checkSavedStatus();
    }
  }

  Future<void> _checkSavedStatus() async {
    if (_property == null) return;

    try {
      // Yeni geliştirdiğimiz getList metodu ile favorileri al
      final savedProperties = await _userService.getSavedProperties();

      // Kaydedilmiş tüm ilanların ID'lerini yazdır
      if (savedProperties.isNotEmpty) {
        for (var item in savedProperties) {
          String? savedId = _extractId(item);

          if (item is Map) {}
        }
      }

      bool isSaved = false;

      // Her bir kayıtlı property için karşılaştırma yap
      for (var item in savedProperties) {
        String? itemId = _extractId(item);

        if (itemId != null) {
          // Tam karşılaştırma
          if (itemId == widget.propertyId) {
            isSaved = true;
            break;
          }

          // MongoDB bazen ObjectId olarak, bazen String olarak döndürüyor
          // Bu nedenle son parçaları karşılaştıralım
          if (itemId.length > 10 && widget.propertyId.length > 10) {
            String item1End = itemId.substring(itemId.length - 10);
            String item2End =
                widget.propertyId.substring(widget.propertyId.length - 10);

            if (item1End == item2End) {
              isSaved = true;
              break;
            }
          }
        }
      }

      // Eğer durum değiştiyse UI'ı güncelle
      if (mounted) {
        setState(() {
          _isFavorite = isSaved;
          if (_propertyData != null) {
            _propertyData!['isSaved'] = isSaved;
          }
        });
      }
    } catch (e) {
      // Favorileri kontrol ederken hata oluştu - sessizce devam et
    }
  }

  // Rezervasyon durumunu kontrol et
  Future<void> _checkReservationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    try {
      // Kullanıcının rezervasyonlarını getir
      final bookings = await _bookingService.getMyBookings();
      
      // Bu mülk için aktif bir rezervasyon var mı kontrol et
      final hasActiveReservation = bookings.any((booking) {
        // booking bir Map ya da Booking objesi olabilir
        final Map bookingData = booking is Map ? booking : (booking as Booking).toJson();
        final String propertyId = bookingData['propertyId'] ?? '';
        final String status = bookingData['status'] ?? '';
        
        return propertyId == widget.propertyId && 
               (status == 'confirmed' || status == 'pending');
      });
      
      if (mounted) {
        setState(() {
          _isReserved = hasActiveReservation;
        });
      }
    } catch (e) {
      print('Rezervasyon durumu kontrol edilirken hata oluştu: $e');
    }
  }

  // Herhangi bir obje veya string'den ID çıkarmaya yardımcı metot
  String? _extractId(dynamic item) {
    try {
      if (item == null) return null;

      // Eğer doğrudan string ise
      if (item is String) {
        return item;
      }

      // Eğer map türünde ise
      if (item is Map) {
        // '_id' anahtarını kontrol et (MongoDB'nin varsayılan ID alanı)
        if (item.containsKey('_id')) {
          return item['_id'].toString();
        }

        // 'id' anahtarını kontrol et (genel ID alanı)
        if (item.containsKey('id')) {
          return item['id'].toString();
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  void _showAllAmenities() {
    if (_property == null) return;

    // Özelliklerden yatak odası, banyo ve misafir sayısını çıkarıyoruz
    List<String> amenitiesOnly = _property!.amenities
        .where((item) =>
            !item.toLowerCase().contains('yatak odası') &&
            !item.toLowerCase().contains('bedroom') &&
            !item.toLowerCase().contains('banyo') &&
            !item.toLowerCase().contains('bath') &&
            !item.toLowerCase().contains('misafir') &&
            !item.toLowerCase().contains('guest'))
        .toList();

    if (amenitiesOnly.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu mülk için dahil olan özellikler belirtilmemiş'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

    // Tüm özellikleri ayrı ayrı ele almak için genişletilmiş liste
    List<String> expandedAmenities = [];

    for (String amenity in amenitiesOnly) {
      // Temizle ve virgülle ayrılmış olanları ayır
      String cleaned = amenity.trim();

      // Tırnak işaretlerini kaldır
      if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      } else if (cleaned.startsWith("'") && cleaned.endsWith("'")) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }

      // İçerideki tırnak işaretlerini temizle
      cleaned = cleaned.replaceAll('"', '').replaceAll("'", '');

      // Virgülle ayrılmış olanları ayır
      if (cleaned.contains(",")) {
        // Her bir parçayı ayrı bir özellik olarak ekle
        List<String> parts = cleaned
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        expandedAmenities.addAll(parts);
      } else {
        // Tek parçalı özellikleri doğrudan ekle
        expandedAmenities.add(cleaned);
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dahil Olan Özellikler'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: expandedAmenities.length,
            itemBuilder: (context, index) {
              String amenity = expandedAmenities[index].trim();

              IconData icon;
              if (amenity.toLowerCase().contains('wifi')) {
                icon = Icons.wifi;
              } else if (amenity.toLowerCase().contains('tv')) {
                icon = Icons.tv;
              } else if (amenity.toLowerCase().contains('mutfak') ||
                  amenity.toLowerCase().contains('kitchen')) {
                icon = Icons.kitchen;
              } else if (amenity.toLowerCase().contains('klima') ||
                  amenity.toLowerCase().contains('air')) {
                icon = Icons.ac_unit;
              } else if (amenity.toLowerCase().contains('havuz') ||
                  amenity.toLowerCase().contains('pool')) {
                icon = Icons.pool;
              } else if (amenity.toLowerCase().contains('balkon')) {
                icon = Icons.balcony;
              } else {
                icon = Icons.check_circle_outline;
              }

              return ListTile(
                leading: Icon(icon),
                title: Text(amenity),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _navigateToHostProfile() {
    if (_property == null) return;

    // Property'den host ID alınabilirse direkt olarak profile git
    if (_propertyData != null) {
      String hostId = "";

      // Doğrudan host ID'si almayı dene
      if (_propertyData!['host'] != null) {
        if (_propertyData!['host'] is Map &&
            _propertyData!['host']['_id'] != null) {
          hostId = _propertyData!['host']['_id'].toString();
        } else if (_propertyData!['host'] is String) {
          hostId = _propertyData!['host'];
        }
      }

      if (hostId.isNotEmpty) {
        // Mevcut kullanıcının ID'sini al
        final currentUser =
            Provider.of<AuthProvider>(context, listen: false).currentUser;

        // Eğer ilan sahibi, oturum açan kullanıcı ise kendi profil sayfasına git
        if (currentUser != null && currentUser.id == hostId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserProfileScreen(),
            ),
          ).then((_) {
            // Profil sayfasından geri döndüğünde favori durumunu tekrar kontrol et
            _checkSavedStatus();
          });
        }
        // Başka bir kullanıcı ise o kullanıcının profil sayfasına git
        else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherUserProfileScreen(userId: hostId),
            ),
          ).then((_) {
            // Profil sayfasından geri döndüğünde favori durumunu tekrar kontrol et
            _checkSavedStatus();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ev sahibi profili bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Rezervasyon butonunu göster
  Widget _buildReserveButton() {
    if (_property == null) return Container();

    // Kullanıcı girişi yapılmamışsa, rezervasyon yapmak için giriş yapma düğmesi göster
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      return ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rezervasyon yapmak için giriş yapmalısınız'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Rezervasyon için Giriş Yap',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Kullanıcının kendi mülkü ise, rezervasyon düğmesini gösterme
    String hostId = "";
    if (_propertyData != null && _propertyData!['host'] != null) {
      if (_propertyData!['host'] is Map && _propertyData!['host']['_id'] != null) {
        hostId = _propertyData!['host']['_id'].toString();
      } else if (_propertyData!['host'] is String) {
        hostId = _propertyData!['host'];
      }
    }

    if (hostId.isNotEmpty && currentUser.id == hostId) {
      return Container();
    }

    // Zaten rezerve edildiyse, "Rezerv edildi" düğmesini göster
    if (_isReserved) {
      return ElevatedButton(
        onPressed: null, // Tıklanamaz
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.grey[400],
        ),
        child: const Text(
          'Rezerv Edildi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Normal rezervasyon düğmesini göster
    return ElevatedButton(
      onPressed: _showBookingModal,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Rezervasyon Yap',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showBookingModal() {
    if (_property == null) return;

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 8));

    DateTime? checkInDate = tomorrow;
    DateTime? checkOutDate = nextWeek;
    int guestCount = 1;
    String? notes;

    int maxGuests = 2;
    for (var amenity in _property!.amenities) {
      if (amenity.toLowerCase().contains('misafir') || amenity.toLowerCase().contains('guest')) {
        var countStr = amenity.replaceAll(RegExp(r'[^0-9]'), '');
        if (countStr.isNotEmpty) {
          maxGuests = int.tryParse(countStr) ?? 2;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rezervasyon',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Giriş tarihi
                    Text(
                      'Giriş Tarihi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: checkInDate ?? tomorrow,
                          firstDate: tomorrow,
                          lastDate: DateTime(now.year + 1),
                        );
                        if (date != null) {
                          setState(() {
                            checkInDate = date;
                            // Eğer çıkış tarihi giriş tarihinden önce ise, çıkış tarihini güncelle
                            if (checkOutDate != null && checkOutDate!.isBefore(date)) {
                              checkOutDate = date.add(const Duration(days: 1));
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              checkInDate != null
                                  ? DateFormat('dd.MM.yyyy').format(checkInDate!)
                                  : 'Tarih seçin',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Çıkış tarihi
                    Text(
                      'Çıkış Tarihi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: checkOutDate ?? nextWeek,
                          firstDate: checkInDate?.add(const Duration(days: 1)) ?? tomorrow.add(const Duration(days: 1)),
                          lastDate: DateTime(now.year + 2),
                        );
                        if (date != null) {
                          setState(() {
                            checkOutDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              checkOutDate != null
                                  ? DateFormat('dd.MM.yyyy').format(checkOutDate!)
                                  : 'Tarih seçin',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Misafir sayısı
                    Text(
                      'Misafir Sayısı',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (guestCount > 1) guestCount--;
                            });
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          guestCount.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (guestCount < maxGuests) guestCount++;
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                        Text('(Max: $maxGuests kişi)'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Notlar
                    Text(
                      'Notlar (Opsiyonel)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Ev sahibine iletmek istediğiniz notlar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        notes = value;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Fiyat hesaplama
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gecelik fiyat:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _property!.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kalış süresi:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          checkInDate != null && checkOutDate != null
                              ? '${checkOutDate!.difference(checkInDate!).inDays} gece'
                              : '0 gece',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Misafir sayısı:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '$guestCount kişi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toplam tutar:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          checkInDate != null && checkOutDate != null
                              ? '${_calculateTotalPrice(checkInDate!, checkOutDate!)} ₺'
                              : '0 ₺',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (checkInDate != null && checkOutDate != null) {
                            _makeReservation(
                              checkInDate!,
                              checkOutDate!,
                              guestCount,
                              notes,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen giriş ve çıkış tarihlerini seçin'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Rezervasyon Yap'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _calculateTotalPrice(DateTime checkIn, DateTime checkOut) {
    if (_property == null) return 0;
    
    final dayDiff = checkOut.difference(checkIn).inDays;
    final priceString = _property!.price.replaceAll(RegExp(r'[^0-9]'), '');
    if (priceString.isEmpty) return 0;
    
    final pricePerNight = int.tryParse(priceString) ?? 0;
    return pricePerNight * dayDiff;
  }

  Future<void> _makeReservation(
    DateTime checkInDate,
    DateTime checkOutDate,
    int guestCount,
    String? notes,
  ) async {
    if (_property == null) return;

    // Yükleniyor göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final bookingService = BookingService();
      await bookingService.createPropertyBooking(
        propertyId: _property!.id,
        startDate: checkInDate.toIso8601String(),
        endDate: checkOutDate.toIso8601String(),
        guestCount: guestCount,
        notes: notes,
      );

      // Dialog kapat
      Navigator.pop(context);
      // Modal kapat
      Navigator.pop(context);

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervasyon talebiniz gönderildi'),
          backgroundColor: Colors.green,
        ),
      );

      // Rezervasyon durumunu güncelle
      setState(() {
        _isReserved = true;
      });
    } catch (e) {
      // Dialog kapat
      Navigator.pop(context);
      
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rezervasyon oluşturulurken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPropertyDetails,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_property == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Mülk bulunamadı')),
      );
    }

    // Özelliklerden yatak odası, banyo ve misafir sayısını çıkarıp ayrı göstereceğiz
    List<String> amenitiesOnly = _property!.amenities
        .where((item) =>
            !item.toLowerCase().contains('yatak odası') &&
            !item.toLowerCase().contains('bedroom') &&
            !item.toLowerCase().contains('banyo') &&
            !item.toLowerCase().contains('bath') &&
            !item.toLowerCase().contains('misafir') &&
            !item.toLowerCase().contains('guest'))
        .toList();

    int bedroomCount = 1;
    int bathroomCount = 1;
    int maxGuests = 2;

    // Property'den yatak odası, banyo ve misafir sayısını alıyoruz
    for (var amenity in _property!.amenities) {
      if (amenity.toLowerCase().contains('yatak odası') ||
          amenity.toLowerCase().contains('bedroom')) {
        var countStr = amenity.replaceAll(RegExp(r'[^0-9]'), '');
        if (countStr.isNotEmpty) {
          bedroomCount = int.tryParse(countStr) ?? 1;
        }
      } else if (amenity.toLowerCase().contains('banyo') ||
          amenity.toLowerCase().contains('bath')) {
        var countStr = amenity.replaceAll(RegExp(r'[^0-9]'), '');
        if (countStr.isNotEmpty) {
          bathroomCount = int.tryParse(countStr) ?? 1;
        }
      } else if (amenity.toLowerCase().contains('misafir') ||
          amenity.toLowerCase().contains('guest')) {
        var countStr = amenity.replaceAll(RegExp(r'[^0-9]'), '');
        if (countStr.isNotEmpty) {
          maxGuests = int.tryParse(countStr) ?? 2;
        }
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  _property!.images.isNotEmpty
                      ? ImageCarousel(
                          images: _property!.images,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SafeArea(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.black,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _property!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _property!.subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _navigateToHostProfile,
                    child: Row(
                      children: [
                        HostProfile(
                          name: _property!.hostName,
                          image: _property!.hostImage,
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Özellikler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dahil Olan Özellikler
                      Expanded(
                        child: GestureDetector(
                          onTap: _showAllAmenities,
                          child: Column(
                            children: [
                              const Icon(Icons.volunteer_activism_outlined,
                                  size: 28),
                              const SizedBox(height: 8),
                              const Text(
                                'Özellikler',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              amenitiesOnly.isNotEmpty
                                  ? const Text(
                                      'Tümünü gör',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFFFF5A5F),
                                        decoration: TextDecoration.underline,
                                      ),
                                    )
                                  : const Text(
                                      '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12),
                                    ),
                            ],
                          ),
                        ),
                      ),

                      // Yatak Odası Sayısı
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.bedroom_parent_outlined, size: 28),
                            const SizedBox(height: 8),
                            const Text(
                              'Yatak Odası',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$bedroomCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF5A5F),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      // Banyo Sayısı
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(Icons.bathtub_outlined, size: 28),
                            const SizedBox(height: 8),
                            const Text(
                              'Banyo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$bathroomCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF5A5F),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      // Misafir Sayısı
                      Expanded(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Misafir',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$maxGuests',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF5A5F),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bu ev hakkında',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _property!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _property!.price,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _property!.perNight ? 'gece' : 'toplam',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildReserveButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_property!.rating}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${_property!.reviewCount} değerlendirme)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
