// ignore_for_file: use_build_context_synchronously

import 'package:estate/models/experience.dart';
import 'package:estate/models/property.dart';
import 'package:estate/screens/experience/experience_detail.dart';
import 'package:estate/screens/experience/experience_list.dart';
import 'package:estate/screens/home/estate_bot_screen.dart';
import 'package:estate/screens/property/property_detail.dart';
import 'package:estate/screens/property/property_list.dart';
import 'package:estate/services/exception/api_exception.dart';
import 'package:estate/services/experience/experience_service.dart';
import 'package:estate/services/property/property_service.dart';
import 'package:estate/services/user/user_service.dart';
import 'package:estate/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom/category_item.dart';
import '../../widgets/experience/experience_card.dart';
import '../../widgets/property/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PropertyService _propertyService = PropertyService();
  final ExperienceService _experienceService = ExperienceService();
  final UserService _userService = UserService();

  List<dynamic> _properties = [];
  List<dynamic> _experiences = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Mülkleri ve deneyimleri paralel olarak yükle
      final results = await Future.wait([
        _propertyService.getProperties(maxResults: 2),
        _experienceService.getExperiences(limit: 4),
      ]);

      setState(() {
        _properties = results[0];
        _experiences = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            e is ApiException ? e.message : 'Veri yüklenirken bir hata oluştu';
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePropertyFavorite(String propertyId) async {
    try {
      // Mülk favorilerden kaldırıldıysa, tekrar ekle
      final property = _properties.firstWhere((p) => p['_id'] == propertyId);
      final isSaved = property['isSaved'] ?? false;

      if (isSaved) {
        await _userService.removeSavedProperty(propertyId);
      } else {
        await _userService.saveProperty(propertyId);
      }

      // UI'ı güncelle
      setState(() {
        property['isSaved'] = !isSaved;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException
              ? e.message
              : 'İşlem sırasında bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Text(
                                  'Keşfet',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const EstateBotScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black38, width: 2),
                                      shape: BoxShape.circle,
                                      color: AppTheme.lightTheme.primaryColor
                                          .withOpacity(0.8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/estate_bot.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  CategoryItem(
                                    icon: 'assets/images/property1.jpg',
                                    title: 'Mülkler',
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const PropertyListScreen()));
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  CategoryItem(
                                    icon: 'assets/images/experience3.jpg',
                                    title: 'Deneyimler',
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ExperienceListScreen()));
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Mülkler',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PropertyListScreen()));
                                  },
                                  child: const Text('Tümünü Gör'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _properties.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('Henüz mülk bulunmuyor'),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _properties.length,
                                    itemBuilder: (context, index) {
                                      final property = _properties[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: PropertyCard(
                                          property: Property.fromJson(property),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PropertyDetailScreen(
                                                            propertyId:
                                                                property[
                                                                    '_id'])));
                                          },
                                          onFavoriteToggle: () {
                                            _togglePropertyFavorite(
                                                property['_id']);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Deneyimler',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ExperienceListScreen()));
                                  },
                                  child: const Text('Tümünü Gör'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _experiences.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('Henüz deneyim bulunmuyor'),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 20,
                                    ),
                                    itemCount: _experiences.length,
                                    itemBuilder: (context, index) {
                                      final experience = _experiences[index];
                                      return ExperienceCard(
                                        experience:
                                            Experience.fromJson(experience),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExperienceDetailScreen(
                                                          experienceId:
                                                              experience[
                                                                  '_id'])));
                                        },
                                      );
                                    },
                                  ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
