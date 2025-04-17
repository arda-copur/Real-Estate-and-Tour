import 'package:flutter/material.dart';
import 'package:estate/models/booking_model.dart';
import 'package:estate/services/booking_service.dart';
import 'package:estate/screens/message_detail_screen.dart';
import 'package:estate/widgets/custom/message_card.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final BookingService _bookingService = BookingService();
  
  bool _isLoading = true;
  List<Booking> _bookings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookingsData = await _bookingService.getHostBookings();
      setState(() {
        _bookings = bookingsData
            .map((data) => Booking.fromJson(data))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // En yeni üstte
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Rezervasyonlar yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
      print('Rezervasyonlar yüklenirken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Kutusu'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBookings,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz hiç rezervasyon isteği yok',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadBookings,
                            child: const Text('Yenile'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBookings,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookings.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          String lastMessage = '';
                          
                          if (booking.status == 'pending') {
                            lastMessage = booking.bookingType == 'property'
                                ? '${booking.formattedStartDate} - ${booking.formattedEndDate} tarihleri için rezervasyon isteği'
                                : '${booking.formattedStartDate} tarihinde ${booking.formattedTimeSlot} saatleri için deneyim rezervasyonu isteği';
                          } else if (booking.status == 'confirmed') {
                            lastMessage = 'Rezervasyon talebini onayladınız';
                          } else if (booking.status == 'cancelled') {
                            lastMessage = 'Rezervasyon talebi reddedildi';
                          } else if (booking.status == 'completed') {
                            lastMessage = 'Rezervasyon tamamlandı';
                          }
                          
                          return MessageCard(
                            hostName: booking.guestName.isNotEmpty ? booking.guestName : 'Misafir',
                            hostImage: booking.guestImage.isNotEmpty
                                ? booking.guestImage
                                : 'assets/images/profile.jpg',
                            propertyName: booking.itemTitle,
                            lastMessage: lastMessage,
                            time: _formatTimeAgo(booking.createdAt),
                            unread: booking.status == 'pending',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageDetailScreen(
                                    booking: booking,
                                  ),
                                ),
                              );
                              
                              // Eğer rezervasyon durumu güncellendiyse, listeyi yeniden yükle
                              if (result == true) {
                                _loadBookings();
                              }
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}
