import 'package:flutter/material.dart';
import '../../widgets/custom/trip_card.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({Key? key}) : super(key: key);

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
              Tab(text: 'İptal Edilen'),
            ],
          ),
        ),
        body: TabBarView(
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TripCard(
          image: 'assets/images/property1.jpg',
          title: 'Miamo - Muhteşem Manzara',
          location: 'Imerovigli, Yunanistan',
          dates: '15-20 Haziran 2023',
          status: TripStatus.upcoming,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPastTrips() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TripCard(
          image: 'assets/images/property2.jpg',
          title: 'Tarihi Taş Ev - Bahçe Manzaralı',
          location: 'Bodrum, Türkiye',
          dates: '10-15 Mayıs 2023',
          status: TripStatus.past,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        TripCard(
          image: 'assets/images/property2.jpg',
          title: 'Modern Daire - Şehir Merkezi',
          location: 'İstanbul, Türkiye',
          dates: '1-5 Nisan 2023',
          status: TripStatus.past,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCancelledTrips() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TripCard(
          image: 'assets/images/property4.jpg',
          title: 'Deniz Manzaralı Villa',
          location: 'Antalya, Türkiye',
          dates: '20-25 Temmuz 2023',
          status: TripStatus.cancelled,
          onTap: () {},
        ),
      ],
    );
  }
}
