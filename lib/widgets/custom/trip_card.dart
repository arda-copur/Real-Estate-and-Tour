import 'package:flutter/material.dart';

enum TripStatus {
  upcoming,
  past,
  cancelled,
}

class TripCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String dates;
  final TripStatus status;
  final Function() onTap;
  final String? cancellationReason;
  final bool reviewButtonVisible;
  final Function()? onReviewPressed;

  const TripCard({
    Key? key,
    required this.image,
    required this.title,
    required this.location,
    required this.dates,
    required this.status,
    required this.onTap,
    this.cancellationReason,
    this.reviewButtonVisible = false,
    this.onReviewPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim ve durum
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: image.startsWith('http') || image.startsWith('https')
                      ? Image.network(
                          image,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 140,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  size: 50, color: Colors.grey),
                            );
                          },
                        )
                      : Image.asset(
                          image,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // Durum etiketi
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // İçerik
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        dates,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // İptal sebebi (eğer varsa)
                  if (status == TripStatus.cancelled &&
                      cancellationReason != null &&
                      cancellationReason!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.red[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'İptal sebebi: $cancellationReason',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Değerlendirme butonu (geçmiş rezervasyonlar için)
                  if (status == TripStatus.past && reviewButtonVisible)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Text(
                              'Tamamlandı',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: onReviewPressed,
                            icon: const Icon(Icons.star, size: 16),
                            label: const Text('Değerlendir'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              minimumSize: const Size(0, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ],
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

  Color _getStatusColor() {
    switch (status) {
      case TripStatus.upcoming:
        return Colors.red;
      case TripStatus.past:
        return Colors.green;
      case TripStatus.cancelled:
        return Colors.amber;
    }
  }

  String _getStatusText() {
    switch (status) {
      case TripStatus.upcoming:
        return 'Yaklaşan';
      case TripStatus.past:
        return 'Geçmiş';
      case TripStatus.cancelled:
        return 'İptal Edildi';
    }
  }
}
