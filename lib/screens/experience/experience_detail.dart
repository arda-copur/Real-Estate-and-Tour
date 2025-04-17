// ignore_for_file: use_build_context_synchronously, empty_catches, unused_local_variable

import 'package:estate/providers/auth_provider.dart';
import 'package:estate/services/exception/api_exception.dart';
import 'package:estate/services/experience/experience_service.dart';
import 'package:estate/services/user/user_service.dart';
import 'package:estate/utils/theme/app_theme.dart';
import 'package:estate/screens/profile/other_user_profile.dart';
import 'package:estate/screens/profile/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experience.dart';
import 'package:intl/intl.dart';
import 'package:estate/models/booking_model.dart';
import 'package:estate/services/booking_service.dart';

class ExperienceDetailScreen extends StatefulWidget {
  final String experienceId;

  const ExperienceDetailScreen({
    Key? key,
    required this.experienceId,
  }) : super(key: key);

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  final ExperienceService _experienceService = ExperienceService();
  final UserService _userService = UserService();

  Map<String, dynamic>? _experienceData;
  Experience? _experience;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadExperienceDetails();

    // Favori durumunu doğrudan kontrol et (API'dan gelen veriye ek olarak)
    // 1 saniye gecikme ekliyoruz, ilk yükleme sırasında API istekleri tamamlanması için
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _checkSavedStatus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sayfaya her giriş yapıldığında ve bağımlılıklar değiştiğinde kontrol et
    if (!_isLoading && _experience != null) {
      _checkSavedStatus();
    }
  }

  Future<void> _loadExperienceDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Deneyim detaylarını yükle
      final experienceData =
          await _experienceService.getExperienceById(widget.experienceId);

      if (experienceData.containsKey('_id')) {}
      if (experienceData.containsKey('id')) {}

      // Eğer kaydedilmiş durumu (isSaved) deneyim verilerinde varsa direkt kullan
      // Yoksa ayrıca kontrol et
      bool isSaved = false;

      // API'den gelen isSaved değerini kontrol et
      if (experienceData.containsKey('isSaved')) {
        try {
          if (experienceData['isSaved'] is bool) {
            isSaved = experienceData['isSaved'];
          } else if (experienceData['isSaved'] == 'true') {
            isSaved = true;
          } else if (experienceData['isSaved'] == 'false') {
            isSaved = false;
          }
        } catch (e) {}
      } else {
        // isSaved değeri yoksa, kullanıcının kaydedilmiş deneyimlerini kontrol et
        try {
          final savedExperiences = await _userService.getSavedExperiences();

          // API'den dönen yanıtı güvenli bir şekilde işle
          for (var item in savedExperiences) {
            try {
              String? itemId = _extractId(item);
              if (itemId == null) continue;

              // Tam karşılaştırma
              if (itemId == widget.experienceId) {
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
        _experienceData = experienceData;
        _experience = Experience.fromJson(experienceData);
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
        await _userService.removeSavedExperience(widget.experienceId);
      } else {
        await _userService.saveExperience(widget.experienceId);
      }

      // UI'ı güncelle
      setState(() {
        _isFavorite = !_isFavorite;
        if (_experienceData != null) {
          _experienceData!['isSaved'] = _isFavorite;
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
    if (_experience == null) return;

    try {
      // Yeni geliştirdiğimiz getList metodu ile favorileri al
      final savedExperiences = await _userService.getSavedExperiences();

      // Kaydedilmiş tüm deneyimlerin ID'lerini yazdır
      if (savedExperiences.isNotEmpty) {
        for (var item in savedExperiences) {
          String? savedId = _extractId(item);

          if (item is Map) {}
        }
      }

      bool isSaved = false;

      // Her bir kayıtlı deneyim için karşılaştırma yap
      for (var item in savedExperiences) {
        String? itemId = _extractId(item);

        if (itemId != null) {
          // Tam karşılaştırma
          if (itemId == widget.experienceId) {
            isSaved = true;
            break;
          }

          // MongoDB bazen ObjectId olarak, bazen String olarak döndürüyor
          // Bu nedenle son parçaları karşılaştıralım
          if (itemId.length > 10 && widget.experienceId.length > 10) {
            String item1End = itemId.substring(itemId.length - 10);
            String item2End =
                widget.experienceId.substring(widget.experienceId.length - 10);

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
          if (_experienceData != null) {
            _experienceData!['isSaved'] = isSaved;
          }
        });
      }
    } catch (e) {
      // Favorileri kontrol ederken hata oluştu - sessizce devam et
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

  void _navigateToHostProfile() {
    if (_experience == null) return;

    // Experience'den host ID alınabilirse direkt olarak profile git
    if (_experienceData != null) {
      String hostId = "";

      // Doğrudan host ID'si almayı dene
      if (_experienceData!['host'] != null) {
        if (_experienceData!['host'] is Map &&
            _experienceData!['host']['_id'] != null) {
          hostId = _experienceData!['host']['_id'].toString();
        } else if (_experienceData!['host'] is String) {
          hostId = _experienceData!['host'];
        }
      }

      if (hostId.isNotEmpty) {
        // Mevcut kullanıcının ID'sini al
        final currentUser =
            Provider.of<AuthProvider>(context, listen: false).currentUser;

        // Eğer deneyim sahibi, oturum açan kullanıcı ise kendi profil sayfasına git
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
            content: Text('Organizatör profili bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Rezervasyon butonunu göster
  Widget _buildReserveButton() {
    if (_experience == null) return Container();

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

    // Kullanıcının kendi deneyimi ise, rezervasyon düğmesini gösterme
    String hostId = "";
    if (_experienceData != null && _experienceData!['host'] != null) {
      if (_experienceData!['host'] is Map && _experienceData!['host']['_id'] != null) {
        hostId = _experienceData!['host']['_id'].toString();
      } else if (_experienceData!['host'] is String) {
        hostId = _experienceData!['host'];
      }
    }

    if (hostId.isNotEmpty && currentUser.id == hostId) {
      return Container();
    }

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

  // Max misafir sayısını deneyimden almaya çalış veya varsayılan değer kullan
  int _getMaxGuests() {
    if (_experienceData != null && _experienceData!.containsKey('maxGuests')) {
      return _experienceData!['maxGuests'] ?? 10;
    }
    return 10; // Varsayılan değer
  }

  void _showBookingModal() {
    if (_experience == null) return;

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    DateTime? selectedDate = tomorrow;
    Map<String, String> timeSlot = {'startTime': '10:00', 'endTime': '12:00'};
    int guestCount = 1;
    String? notes;

    // Max misafir sayısını al
    int maxGuests = _getMaxGuests();

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
                          'Deneyim Rezervasyonu',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Tarih seçimi
                    Text(
                      'Tarih',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? tomorrow,
                          firstDate: tomorrow,
                          lastDate: DateTime(now.year + 2),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
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
                              selectedDate != null
                                  ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                                  : 'Tarih seçin',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Saat aralığı
                    Text(
                      'Saat Aralığı',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.parse(timeSlot['startTime']!.split(':')[0]),
                                  minute: int.parse(timeSlot['startTime']!.split(':')[1]),
                                ),
                              );
                              if (time != null) {
                                setState(() {
                                  timeSlot['startTime'] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
                                  Text(timeSlot['startTime'] ?? '10:00'),
                                  const Icon(Icons.access_time),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(' - '),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.parse(timeSlot['endTime']!.split(':')[0]),
                                  minute: int.parse(timeSlot['endTime']!.split(':')[1]),
                                ),
                              );
                              if (time != null) {
                                setState(() {
                                  timeSlot['endTime'] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
                                  Text(timeSlot['endTime'] ?? '12:00'),
                                  const Icon(Icons.access_time),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
                        hintText: 'Organizatöre iletmek istediğiniz notlar...',
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
                          'Kişi başı fiyat:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _experience!.price,
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
                          _calculateTotalPrice(guestCount),
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
                          if (selectedDate != null) {
                            _makeReservation(selectedDate!, timeSlot, guestCount, notes);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen tarih seçin'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Rezervasyon Talebini Gönder'),
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

  String _calculateTotalPrice(int guestCount) {
    if (_experience == null) return '0 ₺';
    
    final priceString = _experience!.price.replaceAll(RegExp(r'[^0-9]'), '');
    if (priceString.isEmpty) return '0 ₺';
    
    final pricePerPerson = int.tryParse(priceString) ?? 0;
    final totalPrice = pricePerPerson * guestCount;
    
    return '$totalPrice ₺';
  }

  Future<void> _makeReservation(
    DateTime selectedDate,
    Map<String, String> timeSlot,
    int guestCount,
    String? notes,
  ) async {
    if (_experience == null) return;

    // Yükleniyor göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final bookingService = BookingService();
      await bookingService.createExperienceBooking(
        experienceId: _experience!.id,
        startDate: selectedDate.toIso8601String(),
        timeSlot: timeSlot,
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
                onPressed: _loadExperienceDetails,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_experience == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Deneyim bulunamadı')),
      );
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
                  _experience!.image.isNotEmpty
                      ? Image.network(
                          _experience!.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
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
                    _experience!.category,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _experience!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_experience!.rating}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${_experience!.reviewCount} değerlendirme)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _navigateToHostProfile,
                    child: Row(
                      children: [
                        _experience!.hostImage.isNotEmpty
                            ? CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    NetworkImage(_experience!.hostImage),
                                onBackgroundImageError: (e, s) => {},
                                backgroundColor: Colors.grey[300],
                                child: _experience!.hostImage.isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.grey)
                                    : null,
                              )
                            : CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.person,
                                    color: Colors.grey),
                              ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Organizatör: ${_experience!.hostName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Lokasyon : ${_experience!.location}",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.lightTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Deneyim hakkında',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _experience!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.insert_chart_outlined_rounded,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Dahil olanlar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._experience!.included.isEmpty
                      ? [const Text('Bilgi belirtilmemiş')]
                      : _experience!.included
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Notlar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _experience!.subtitle,
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
                            _experience!.price,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'kişi başı',
                            style: TextStyle(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
