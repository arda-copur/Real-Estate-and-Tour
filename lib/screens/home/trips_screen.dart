import 'package:flutter/material.dart';
import 'package:estate/models/booking_model.dart';
import 'package:estate/services/booking_service.dart';
import 'package:estate/widgets/custom/trip_card.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class TripsScreen extends StatefulWidget {
  const TripsScreen({Key? key}) : super(key: key);

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
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
      final bookingsData = await _bookingService.getMyBookings();
      setState(() {
        _bookings = bookingsData.map((data) => Booking.fromJson(data)).toList();
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gezilerim'),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF5A5F),
            tabs: [
              Tab(text: 'Yaklaşan'),
              Tab(text: 'Geçmiş'),
              Tab(text: 'Reddilen'),
            ],
          ),
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
                : TabBarView(
                    children: [
                      _buildUpcomingTrips(),
                      _buildPastTrips(),
                      _buildCancelledTrips(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildUpcomingTrips() {
    // Yaklaşan rezervasyonlar (onaylanmış ve tarihi gelmemiş)
    final upcomingBookings = _bookings.where((booking) {
      final isConfirmed = booking.status == 'confirmed';
      final isUpcoming = booking.bookingType == 'property'
          ? booking.startDate.isAfter(DateTime.now())
          : booking.startDate
              .isAfter(DateTime.now().subtract(const Duration(days: 1)));
      return isConfirmed && isUpcoming;
    }).toList();

    if (upcomingBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Yaklaşan rezervasyonunuz bulunmuyor',
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
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcomingBookings.length,
        itemBuilder: (context, index) {
          final booking = upcomingBookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TripCard(
              image: booking.itemImage.isNotEmpty
                  ? booking.itemImage
                  : 'assets/images/property${Random().nextInt(4) + 1}.jpg',
              title: booking.itemTitle,
              location: booking.itemLocation,
              dates: booking.bookingType == 'property'
                  ? '${booking.formattedStartDate} - ${booking.formattedEndDate}'
                  : '${booking.formattedStartDate} (${booking.formattedTimeSlot})',
              status: TripStatus.upcoming,
              onTap: () {
                // Rezervasyon detaylarına git
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPastTrips() {
    // Geçmiş rezervasyonlar (onaylanmış ve tarihi geçmiş)
    final pastBookings = _bookings.where((booking) {
      final isConfirmed = booking.status == 'confirmed';
      final isPast = booking.bookingType == 'property'
          ? booking.endDate != null && booking.endDate!.isBefore(DateTime.now())
          : booking.startDate
              .isBefore(DateTime.now().subtract(const Duration(days: 1)));
      return isConfirmed && isPast;
    }).toList();

    if (pastBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Geçmiş rezervasyonunuz bulunmuyor',
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
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastBookings.length,
        itemBuilder: (context, index) {
          final booking = pastBookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TripCard(
              image: booking.itemImage.isNotEmpty
                  ? booking.itemImage
                  : 'assets/images/property${Random().nextInt(4) + 1}.jpg',
              title: booking.itemTitle,
              location: booking.itemLocation,
              dates: booking.bookingType == 'property'
                  ? '${booking.formattedStartDate} - ${booking.formattedEndDate}'
                  : '${booking.formattedStartDate} (${booking.formattedTimeSlot})',
              status: TripStatus.past,
              onTap: () {
                // Rezervasyon detaylarına git
              },
              reviewButtonVisible: !booking.hasReview,
              onReviewPressed: () {
                _showReviewDialog(booking);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCancelledTrips() {
    // İptal edilen rezervasyonlar
    final cancelledBookings = _bookings.where((booking) {
      return booking.status == 'cancelled';
    }).toList();

    if (cancelledBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Reddedilen rezervasyonunuz bulunmuyor',
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
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cancelledBookings.length,
        itemBuilder: (context, index) {
          final booking = cancelledBookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TripCard(
              image: booking.itemImage.isNotEmpty
                  ? booking.itemImage
                  : 'assets/images/property${Random().nextInt(4) + 1}.jpg',
              title: booking.itemTitle,
              location: booking.itemLocation,
              dates: booking.bookingType == 'property'
                  ? '${booking.formattedStartDate} - ${booking.formattedEndDate}'
                  : '${booking.formattedStartDate} (${booking.formattedTimeSlot})',
              status: TripStatus.cancelled,
              cancellationReason: booking.cancellationReason,
              onTap: () {
                // Rezervasyon detaylarına git
              },
            ),
          );
        },
      ),
    );
  }

  void _showReviewDialog(Booking booking) {
    final TextEditingController commentController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  '${booking.bookingType == 'property' ? 'Mülk' : 'Deneyim'} Değerlendirme'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.itemTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Puanınız'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 1; i <= 5; i++)
                          IconButton(
                            icon: Icon(
                              i <= rating ? Icons.star : Icons.star_border,
                              color: i <= rating ? Colors.amber : Colors.grey,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                rating = i.toDouble();
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Yorumunuz'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Deneyiminizi paylaşın...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // TODO: Değerlendirme gönderme API'si eklenecek
                    Navigator.of(context).pop();

                    // Başarı mesajı göster
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Değerlendirmeniz için teşekkürler!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Rezervasyonları yeniden yükle
                    _loadBookings();
                  },
                  child: const Text('Gönder'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
