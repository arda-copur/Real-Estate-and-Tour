import 'package:estate/providers/auth_provider.dart';
import 'package:estate/screens/app/about_screen.dart';
import 'package:estate/screens/experience/create_experience_screen.dart';
import 'package:estate/screens/app/help_center_screen.dart';
import 'package:estate/screens/property/list_property_screen.dart';
import 'package:estate/screens/auth/login_screen.dart';
import 'package:estate/screens/app/support_screen.dart';
import 'package:estate/screens/profile/user_profile_screen.dart';
import 'package:estate/screens/app/welcome_screen.dart';
import 'package:estate/widgets/profile/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Kullanıcı oturum açmamışsa giriş ekranına yönlendir
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bu sayfayı görüntülemek için\ngiriş yapmalısınız',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserProfileScreen()));
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user.profileImage.isNotEmpty
                            ? NetworkImage(user.profileImage)
                            : const AssetImage('assets/images/profile.jpg')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Profili Görüntüle',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFFF5A5F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Hesap',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Kişisel Bilgiler',
                  onTap: () {
                    // Kişisel bilgiler sayfasına git
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Gizlilik ve Paylaşım',
                  onTap: () {
                    // Gizlilik sayfasına git
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'Ev Sahipliği',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ProfileMenuItem(
                  icon: Icons.home_outlined,
                  title: 'Evinizi Kiralayın',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListPropertyScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.event_available_outlined,
                  title: 'Bir Deneyim Düzenleyin',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateExperienceScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'Destek',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Yardım Merkezi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Destek İletişimi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: 'Hakkında',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            await authProvider.logout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Çıkış yapıldı'),
                                  backgroundColor: Color(0xFFFF5A5F),
                                ),
                              );
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WelcomeScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : const Text(
                            'Çıkış Yap',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
