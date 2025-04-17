// ignore_for_file: prefer_final_fields

import 'dart:io';
import 'package:estate/services/exception/api_exception.dart';
import 'package:estate/services/experience/experience_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateExperienceScreen extends StatefulWidget {
  const CreateExperienceScreen({Key? key}) : super(key: key);

  @override
  State<CreateExperienceScreen> createState() => _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends State<CreateExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  String _experienceType = 'Yemek';
  int _duration = 2;
  int _maxGuests = 6;
  List<String> _included = [];
  File? _experienceImage;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _experienceTypes = [
    'Yemek',
    'Sanat',
    'Doğa',
    'Spor',
    'Tarih',
    'Müzik',
    'Dans',
    'Fotoğrafçılık'
  ];

  final List<String> _availableInclusions = [
    'Ekipman',
    'Yemek',
    'İçecek',
    'Ulaşım',
    'Fotoğraf',
    'Hatıra',
    'Rehberlik',
    'Ders Notları'
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

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
                    maxWidth: 1280,
                    maxHeight: 720,
                    imageQuality: 80,
                  );

                  if (pickedFile != null) {
                    setState(() {
                      _experienceImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Fotoğraf Çek'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1280,
                    maxHeight: 720,
                    imageQuality: 80,
                  );

                  if (pickedFile != null) {
                    setState(() {
                      _experienceImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitExperience() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_experienceImage == null) {
      setState(() {
        _errorMessage = 'Lütfen bir deneyim fotoğrafı ekleyin';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ExperienceService sınıfını oluştur
      final experienceService = ExperienceService();

      // Deneyim oluştur
      await experienceService.createExperience(
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: int.parse(_priceController.text.trim()),
          duration: _duration.toString(),
          location: _locationController.text.trim(),
          category: _experienceType,
          maxGuests: _maxGuests,
          image: _experienceImage!,
          // Dahil olanlar alanı - included olarak gönderilecek
          includes: _included);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deneyiminiz başarıyla oluşturuldu!'),
            backgroundColor: Color(0xFFFF5A5F),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e is ApiException
              ? e.message
              : 'Deneyim oluşturulurken bir hata oluştu';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deneyim Oluştur'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bir Deneyim Düzenleyin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tutkunuzu ve uzmanlığınızı paylaşarak misafirlerinize unutulmaz anlar yaşatın.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Fotoğraf Ekleme
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          image: _experienceImage != null
                              ? DecorationImage(
                                  image: FileImage(_experienceImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _experienceImage == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      'Fotoğraf Ekle',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (_errorMessage != null && _experienceImage == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Başlık
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        hintText: 'Örn: İtalyan Mutfağı Yemek Kursu',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir başlık girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Alt Başlık
                    TextFormField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Alt Başlık',
                        hintText: 'Örn: Gerçek İtalyan şefi ile yemek yapın',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir alt başlık girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Açıklama
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        hintText: 'Deneyiminizi detaylı bir şekilde tanıtın',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir açıklama girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Konum
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Konum',
                        hintText: 'Örn: İstanbul, Türkiye',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir konum girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Deneyim Tipi
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Deneyim Tipi',
                        border: OutlineInputBorder(),
                      ),
                      value: _experienceType,
                      items: _experienceTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _experienceType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fiyat
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Kişi Başı Fiyat (₺)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir fiyat girin';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Lütfen geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Süre ve Maksimum Misafir Sayısı
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Süre (Saat)'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: _duration > 1
                                        ? () {
                                            setState(() {
                                              _duration--;
                                            });
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '$_duration',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        _duration++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Maksimum Misafir'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: _maxGuests > 1
                                        ? () {
                                            setState(() {
                                              _maxGuests--;
                                            });
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '$_maxGuests',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        _maxGuests++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dahil Olanlar
                    const Text(
                      'Dahil Olanlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableInclusions.map((item) {
                        final isSelected = _included.contains(item);
                        return FilterChip(
                          label: Text(item),
                          selectedColor: Colors.redAccent,
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _included.add(item);
                              } else {
                                _included.remove(item);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Kaydet Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitExperience,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Deneyimi Yayınla',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
