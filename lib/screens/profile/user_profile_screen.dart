// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:estate/providers/auth_provider.dart';
import 'package:estate/services/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:estate/models/user_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _imageFile;
  bool _isUploading = false;
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Kullanıcı bilgilerini API'den doğrudan yükle
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userService = UserService();
      final userData = await userService.getUserProfile();

      setState(() {
        _user = User.fromJson(userData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Kullanıcıya fotoğraf kaynağı seçme seçeneği sunulur
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                    _uploadImage();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera ile Çek'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                    _uploadImage();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isUploading = true;
    });

    try {
      final success = await authProvider.uploadProfileImage(_imageFile!);

      if (mounted) {
        if (success) {
          // Profil resmi başarıyla yüklendi, kullanıcı bilgilerini yenile
          await _loadUserData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil fotoğrafı başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Profil düzenleme dialog'ını göster
  void _showEditProfileDialog() {
    if (_user == null) return;

    // Form controller'ları oluştur ve mevcut değerlerle doldur
    final TextEditingController firstNameController =
        TextEditingController(text: _user!.firstName);
    final TextEditingController lastNameController =
        TextEditingController(text: _user!.lastName);
    final TextEditingController phoneController =
        TextEditingController(text: _user!.phone ?? '');
    final TextEditingController ageController =
        TextEditingController(text: _user!.age?.toString() ?? '');
    final TextEditingController cityController =
        TextEditingController(text: _user!.city ?? '');
    final TextEditingController bioController =
        TextEditingController(text: _user!.bio ?? '');

    // Form Key
    final formKey = GlobalKey<FormState>();

    // Profili güncelleme işleminde kullanılacak değişkenleri tanımla
    bool isUpdating = false;
    String? updateError;

    // Dialog göster
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Profili güncelleme fonksiyonu
            Future<void> updateProfile() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              setState(() {
                isUpdating = true;
                updateError = null;
              });

              try {
                // Age değerini int'e çevir
                int? age;
                if (ageController.text.isNotEmpty) {
                  age = int.tryParse(ageController.text);
                }

                // UserService ile profili güncelle
                final userService = UserService();
                await userService.updateUserProfile(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  phone: phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  age: age,
                  city:
                      cityController.text.isEmpty ? null : cityController.text,
                  bio: bioController.text.isEmpty ? null : bioController.text,
                );

                // Dialog'ı kapat
                Navigator.of(context).pop();

                // Kullanıcı bilgilerini doğrudan API'den yeniden çek
                await _loadUserData();

                // Başarı mesajını göster
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil başarıyla güncellendi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                setState(() {
                  updateError = e.toString();
                  isUpdating = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Profili Düzenle'),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ad
                        TextFormField(
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Ad',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ad boş olamaz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Soyad
                        TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Soyad',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Soyad boş olamaz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Telefon
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Telefon',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),

                        // Yaş
                        TextFormField(
                          controller: ageController,
                          decoration: const InputDecoration(
                            labelText: 'Yaş',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (int.tryParse(value) == null) {
                                return 'Geçerli bir yaş giriniz';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Şehir
                        TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(
                            labelText: 'Şehir',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Biyografi
                        TextFormField(
                          controller: bioController,
                          decoration: const InputDecoration(
                            labelText: 'Hakkımda',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),

                        // Hata Mesajı
                        if (updateError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              updateError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isUpdating ? null : () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: isUpdating ? null : updateProfile,
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bulunamadı')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _user!.profileImage.isNotEmpty
                            ? NetworkImage(_user!.profileImage)
                            : const AssetImage('assets/images/profile.jpg')
                                as ImageProvider,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5A5F),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt,
                                    color: Colors.white),
                            onPressed: _isUploading ? null : _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_user!.formattedCreatedAt} beri üye',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Profili düzenle
                      _showEditProfileDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Profili Düzenle'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hakkında',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user!.bio ?? 'Henüz hakkında bilgisi eklenmemiş.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Konum
                  if (_user!.city != null && _user!.city!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Konum',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _user!.city!,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  const Text(
                    'Değerlendirmeler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    'Burak',
                    'assets/images/host2.jpg',
                    'Mehmet mükemmel bir misafirdi. Evi çok temiz bıraktı ve iletişim kurmak çok kolaydı.',
                    '2 ay önce',
                  ),
                  const Divider(),
                  _buildReviewItem(
                    'Ayça',
                    'assets/images/host3.jpg',
                    'Harika bir misafir! Tekrar ağırlamaktan mutluluk duyarım.',
                    '4 ay önce',
                  ),
                  const Divider(),
                  _buildReviewItem(
                    'Jacob',
                    'assets/images/host.jpg',
                    'Çok nazik ve saygılı bir misafir. Kesinlikle tavsiye ederim.',
                    '6 ay önce',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Doğrulanmış Bilgiler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVerificationItem(Icons.email, 'E-posta adresi'),
                  _buildVerificationItem(Icons.phone, 'Telefon numarası'),
                  _buildVerificationItem(Icons.badge, 'Kimlik'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(
      String name, String image, String review, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(review),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(text),
          const Spacer(),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
