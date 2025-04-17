import 'package:estate/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:estate/models/booking_model.dart';
import 'package:estate/services/booking_service.dart';
import 'package:intl/intl.dart';

class MessageDetailScreen extends StatefulWidget {
  final Booking booking;

  const MessageDetailScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;
  String? _error;

  Future<void> _updateBookingStatus(String status) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _bookingService.updateBookingStatus(
        bookingId: widget.booking.id,
        status: status,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'confirmed'
                ? 'Rezervasyon talebini onayladınız'
                : 'Rezervasyon talebini reddettiniz',
          ),
          backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
        ),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context, true); // Rezervasyon durumu güncellendi
    } catch (e) {
      setState(() {
        _error = 'Rezervasyon durumu güncellenirken bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Booking booking = widget.booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon Detayı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8.0),
                          Expanded(child: Text(_error!)),
                        ],
                      ),
                    ),
                  // İlan ve kullanıcı bilgileri
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: booking.itemImage.isNotEmpty
                            ? Image.network(
                                booking.itemImage,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey,
                                child: const Icon(Icons.image_not_supported),
                              ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.itemTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            Text(booking.itemLocation),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundImage: booking.guestImage.isNotEmpty
                                      ? NetworkImage(booking.guestImage)
                                      : const AssetImage(
                                              'assets/images/profile.jpg')
                                          as ImageProvider,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  booking.guestName.isNotEmpty
                                      ? booking.guestName
                                      : 'Misafir',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // Rezervasyon bilgileri
                  const Text(
                    'Rezervasyon Bilgileri',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildInfoRow('Durum', booking.statusText),
                  _buildInfoRow('Ödeme Durumu', booking.paymentStatusText),
                  _buildInfoRow(
                      'Misafir Sayısı', booking.guestCount.toString()),
                  _buildInfoRow('Toplam Fiyat', booking.formattedTotalPrice),
                  if (booking.bookingType == 'property') ...[
                    _buildInfoRow('Giriş Tarihi', booking.formattedStartDate),
                    _buildInfoRow('Çıkış Tarihi', booking.formattedEndDate),
                  ] else if (booking.bookingType == 'experience') ...[
                    _buildInfoRow('Tarih', booking.formattedStartDate),
                    if (booking.timeSlot != null)
                      _buildInfoRow('Saat', booking.formattedTimeSlot),
                  ],
                  if (booking.notes != null && booking.notes!.isNotEmpty)
                    _buildInfoRow('Notlar', booking.notes!),
                  const SizedBox(height: 24.0),
                  // Rezervasyon tarihi
                  Text(
                    'Rezervasyon talebi: ${DateFormat('dd.MM.yyyy HH:mm').format(booking.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  // İşlem butonları
                  if (booking.status == 'pending')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateBookingStatus('cancelled'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text('Reddet'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateBookingStatus('confirmed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text('Onayla'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (booking.status == 'confirmed')
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Bu rezervasyon talebini onayladınız',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (booking.status == 'cancelled')
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Bu rezervasyon talebi reddedildi',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
