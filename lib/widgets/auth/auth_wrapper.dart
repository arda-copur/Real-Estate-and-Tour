import 'package:estate/providers/auth_provider.dart';
import 'package:estate/screens/home/main_screen.dart';
import 'package:estate/screens/app/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Build tamamlandıktan sonra initAuth'ı çağır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAuth();
    });
  }

  Future<void> _initAuth() async {
    try {
      await context.read<AuthProvider>().initAuth();
    } catch (e) {
      // Hata durumunda bile isInitializing'i false yapmalıyız
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Hala başlatılıyor veya yükleniyor ise yükleme ekranı göster
    if (_isInitializing || authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF5A5F),
          ),
        ),
      );
    }

    // Kullanıcı giriş yapmış mı kontrol et
    return authProvider.currentUser != null
        ? const MainScreen()
        : const WelcomeScreen();
  }
}
