import 'package:estate/screens/experience/experience_detail.dart';
import 'package:estate/services/exception/api_exception.dart';
import 'package:estate/services/experience/experience_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/experience/experience_card.dart';
import '../../widgets/search/filter_bottom_sheet.dart';
import '../../models/experience.dart';

class ExperienceListScreen extends StatefulWidget {
  const ExperienceListScreen({Key? key}) : super(key: key);

  @override
  State<ExperienceListScreen> createState() => _ExperienceListScreenState();
}

class _ExperienceListScreenState extends State<ExperienceListScreen> {
  final ExperienceService _experienceService = ExperienceService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _experiences = [];
  List<dynamic> _filteredExperiences = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  // Filtreler
  List<String>? _locations;
  List<RangeValues>? _priceRanges;
  String? _category;

  // Filtre uygulandı mı kontrolü
  bool get _isFilterApplied =>
      _searchQuery.isNotEmpty ||
      (_locations != null && _locations!.isNotEmpty) ||
      (_priceRanges != null && _priceRanges!.isNotEmpty) ||
      _category != null;

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExperiences() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final experiences = await _experienceService.getExperiences();

      setState(() {
        _experiences = experiences;
        _filteredExperiences = experiences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is ApiException
            ? e.message
            : 'Deneyimler yüklenirken bir hata oluştu';
        _isLoading = false;
      });
    }
  }

  void _searchExperiences(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    _applyFilters();
  }

  // Türkçe karakterleri normalize eden yardımcı fonksiyon
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g');
  }

  void _applyFilters(
      {List<String>? locations,
      List<RangeValues>? priceRanges,
      String? category}) {
    // Arama ve filtreleme için parametreleri güncelle
    if (locations != null) _locations = locations;
    if (priceRanges != null) _priceRanges = priceRanges;
    if (category != null) _category = category;

    setState(() {
      _filteredExperiences = _experiences.where((experience) {
        // Arama sorgusu
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          final title = _normalizeText(experience['title']?.toString() ?? '');
          final location =
              _normalizeText(experience['location']?.toString() ?? '');
          final category =
              _normalizeText(experience['category']?.toString() ?? '');
          final hostName =
              _normalizeText(experience['hostName']?.toString() ?? '');
          final normalizedQuery = _normalizeText(_searchQuery);

          matchesSearch = title.contains(normalizedQuery) ||
              location.contains(normalizedQuery) ||
              category.contains(normalizedQuery) ||
              hostName.contains(normalizedQuery);
        }

        // Konum filtresi
        bool matchesLocation = true;
        if (_locations != null && _locations!.isNotEmpty) {
          final experienceLocation =
              _normalizeText(experience['location']?.toString() ?? '');

          matchesLocation = _locations!.any((loc) {
            final normalizedLocation = _normalizeText(loc);
            return experienceLocation.contains(normalizedLocation);
          });
        }

        // Fiyat aralığı filtresi
        bool matchesPriceRange = true;
        if (_priceRanges != null && _priceRanges!.isNotEmpty) {
          final priceString = experience['price']?.toString() ?? '0';
          final price =
              int.tryParse(priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

          // Herhangi bir fiyat aralığına uyuyorsa true döndür
          matchesPriceRange = _priceRanges!
              .any((range) => price >= range.start && price <= range.end);
        }

        // Kategori filtresi
        bool matchesCategory = true;
        if (_category != null && _category!.isNotEmpty) {
          final experienceCategory =
              _normalizeText(experience['category']?.toString() ?? '');
          final normalizedCategory = _normalizeText(_category!);
          matchesCategory = experienceCategory.contains(normalizedCategory);
        }

        return matchesSearch &&
            matchesLocation &&
            matchesPriceRange &&
            matchesCategory;
      }).toList();
    });
  }

  // Tüm filtreleri temizle
  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _locations = null;
      _priceRanges = null;
      _category = null;
      _searchController.clear();
      _filteredExperiences = _experiences;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterBottomSheet(
        onApplyFilters: (locations, priceRanges, _) {
          _applyFilters(
            locations: locations,
            priceRanges: priceRanges,
          );
        },
        isExperience: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(6),
            hintText: 'Konum, kategori ara...',
            border: InputBorder.none,
          ),
          onChanged: _searchExperiences,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtreleri temizle butonu (sadece filtre uygulandığında görünür)
          if (_isFilterApplied)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Text(
                    'Aktif Filtreler:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_searchQuery.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text('Arama: $_searchQuery'),
                                backgroundColor: Colors.grey[200],
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                          if (_locations != null && _locations!.isNotEmpty)
                            ..._locations!.map((location) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text('Konum: $location'),
                                    backgroundColor: Colors.grey[200],
                                    labelStyle: const TextStyle(fontSize: 12),
                                  ),
                                )),
                          if (_priceRanges != null && _priceRanges!.isNotEmpty)
                            ..._priceRanges!.map((range) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text(
                                        'Fiyat: ${range.start.toInt()}-${range.end.toInt()}₺'),
                                    backgroundColor: Colors.grey[200],
                                    labelStyle: const TextStyle(fontSize: 12),
                                  ),
                                )),
                          if (_category != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text('Kategori: $_category'),
                                backgroundColor: Colors.grey[200],
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),
          // Ana içerik
          Expanded(
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
                              onPressed: _loadExperiences,
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : _filteredExperiences.isEmpty
                        ? const Center(child: Text('Sonuç bulunamadı'))
                        : RefreshIndicator(
                            onRefresh: _loadExperiences,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredExperiences.length,
                              itemBuilder: (context, index) {
                                final experience = _filteredExperiences[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: ExperienceCard(
                                    experience: Experience.fromJson(experience),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ExperienceDetailScreen(
                                                  experienceId:
                                                      experience['_id']),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
