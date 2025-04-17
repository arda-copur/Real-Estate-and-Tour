// ignore_for_file: use_build_context_synchronously, empty_catches

import 'package:estate/services/experience/experience_service.dart';
import 'package:estate/services/property/property_service.dart';
import 'package:estate/services/user/user_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/property/saved_property_card.dart';
import '../../models/property.dart';
import '../../models/experience.dart';
import '../property/property_detail.dart';
import '../experience/experience_detail.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final UserService _userService = UserService();
  final PropertyService _propertyService = PropertyService();
  final ExperienceService _experienceService = ExperienceService();

  List<Property> _savedProperties = [];
  List<Experience> _savedExperiences = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  Future<void> _loadSavedItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Kaydedilmiş mülkleri API'den al
      final savedPropertiesData = await _userService.getSavedProperties();

      // Kaydedilmiş deneyimleri API'den al
      final savedExperiencesData = await _userService.getSavedExperiences();

      // Verileri modellerimize dönüştür
      List<Property> properties = [];
      List<Experience> experiences = [];

      // Mülkleri dönüştür
      for (var item in savedPropertiesData) {
        try {
          // Eğer veri tam bir mülk değilse, detayları getir
          if (item is Map &&
              (item.containsKey('_id') || item.containsKey('id'))) {
            String propertyId = item.containsKey('_id')
                ? item['_id'].toString()
                : item['id'].toString();
            final propertyDetails =
                await _propertyService.getPropertyById(propertyId);
            properties.add(Property.fromJson(propertyDetails));
          } else if (item is String) {
            // Eğer sadece ID ise, detayları getir
            final propertyDetails =
                await _propertyService.getPropertyById(item);
            properties.add(Property.fromJson(propertyDetails));
          }
        } catch (e) {}
      }

      // Deneyimleri dönüştür
      for (var item in savedExperiencesData) {
        try {
          // Eğer veri tam bir deneyim değilse, detayları getir
          if (item is Map &&
              (item.containsKey('_id') || item.containsKey('id'))) {
            String experienceId = item.containsKey('_id')
                ? item['_id'].toString()
                : item['id'].toString();
            final experienceDetails =
                await _experienceService.getExperienceById(experienceId);
            experiences.add(Experience.fromJson(experienceDetails));
          } else if (item is String) {
            // Eğer sadece ID ise, detayları getir
            final experienceDetails =
                await _experienceService.getExperienceById(item);
            experiences.add(Experience.fromJson(experienceDetails));
          }
        } catch (e) {}
      }

      setState(() {
        _savedProperties = properties;
        _savedExperiences = experiences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Kaydedilen öğeler yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  // Mülkü favorilerden kaldır
  Future<void> _removePropertyFromFavorites(String propertyId) async {
    try {
      await _userService.removeSavedProperty(propertyId);
      // Favorilerden kaldırıldıktan sonra listeyi güncelle
      setState(() {
        _savedProperties.removeWhere((property) => property.id == propertyId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mülk favorilerinizden kaldırıldı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mülk kaldırılırken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Deneyimi favorilerden kaldır
  Future<void> _removeExperienceFromFavorites(String experienceId) async {
    try {
      await _userService.removeSavedExperience(experienceId);
      // Favorilerden kaldırıldıktan sonra listeyi güncelle
      setState(() {
        _savedExperiences
            .removeWhere((experience) => experience.id == experienceId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deneyim favorilerinizden kaldırıldı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deneyim kaldırılırken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kaydedilenler'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kaydedilenler'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSavedItems,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaydedilenler'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSavedItems,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kaydedilen Mülkler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _savedProperties.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Text(
                          'Henüz kaydedilmiş ev bulunmuyor',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _savedProperties.length,
                      itemBuilder: (context, index) {
                        final property = _savedProperties[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: SavedPropertyCard(
                            image: property.images.isNotEmpty
                                ? property.images[0]
                                : '',
                            title: property.title,
                            location: property.location,
                            price: property.price,
                            rating: property.rating,
                            onTap: () {
                              // Mülk detay sayfasına git
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailScreen(
                                    propertyId: property.id,
                                  ),
                                ),
                              ).then((_) => _loadSavedItems());
                            },
                            onRemove: () {
                              // Favorilerden kaldır
                              _removePropertyFromFavorites(property.id);
                            },
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 24),
              const Text(
                'Kaydedilen Deneyimler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _savedExperiences.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Text(
                          'Henüz kaydedilmiş deneyim bulunmuyor',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _savedExperiences.length,
                      itemBuilder: (context, index) {
                        final experience = _savedExperiences[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: SavedPropertyCard(
                            image: experience.image,
                            title: experience.title,
                            location: experience.location,
                            price: experience.price,
                            rating: experience.rating,
                            onTap: () {
                              // Deneyim detay sayfasına git
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExperienceDetailScreen(
                                    experienceId: experience.id,
                                  ),
                                ),
                              ).then((_) => _loadSavedItems());
                            },
                            onRemove: () {
                              // Favorilerden kaldır
                              _removeExperienceFromFavorites(experience.id);
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
