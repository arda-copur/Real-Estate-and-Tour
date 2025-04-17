import 'package:flutter/material.dart';
import '../../widgets/custom/message_card.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Kutusu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MessageCard(
            hostName: 'Burak',
            hostImage: 'assets/images/host2.jpg',
            propertyName: '**MERKEZ** Doğa Evi',
            lastMessage:
                'Merhaba! Rezervasyonunuz onaylandı. Herhangi bir sorunuz varsa bana yazabilirsiniz.',
            time: '2 saat önce',
            unread: true,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          MessageCard(
            hostName: 'Marco',
            hostImage: 'assets/images/host.jpg',
            propertyName: 'Miamo - Muhteşem Manzara',
            lastMessage:
                'Umarım güzel bir konaklama geçirmişsinizdir. Değerlendirme yapmayı unutmayın!',
            time: '2 gün önce',
            unread: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
