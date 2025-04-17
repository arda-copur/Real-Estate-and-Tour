import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFFF5A5F),
                child: Icon(
                  Icons.home,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Emlak Uygulaması',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Sürüm 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Uygulama Hakkında',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Emlak Uygulaması, dünyanın her yerinden benzersiz konaklama yerleri ve deneyimler bulmanızı sağlayan bir platformdur. İster bir tatil, iş seyahati veya uzun süreli konaklama için olsun, ihtiyaçlarınıza uygun seçenekler sunuyoruz.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Misyonumuz',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Misyonumuz, insanların dünyanın her yerinde kendilerini evlerinde hissetmelerini sağlamaktır. Yerel toplulukları destekleyerek ve benzersiz konaklama deneyimleri sunarak, seyahat etmenin daha anlamlı ve erişilebilir olmasını hedefliyoruz.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'İletişim',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildContactItem(Icons.email, 'destek@emlakuygulamasi.com'),
            _buildContactItem(Icons.phone, '+90 212 123 45 67'),
            _buildContactItem(Icons.location_on, 'İstanbul, Türkiye'),
            const SizedBox(height: 24),
            const Text(
              'Sosyal Medya',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(Icons.facebook, 'Facebook'),
                _buildSocialButton(Icons.camera_alt, 'Instagram'),
                _buildSocialButton(Icons.flutter_dash, 'Twitter'),
                _buildSocialButton(Icons.video_library, 'YouTube'),
              ],
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '© 2023 Emlak Uygulaması. Tüm hakları saklıdır.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF5A5F)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String platform) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          color: const Color(0xFFFF5A5F),
          onPressed: () {
            // Sosyal medya sayfasına yönlendir
          },
        ),
        Text(platform),
      ],
    );
  }
}
