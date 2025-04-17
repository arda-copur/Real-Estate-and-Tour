// ignore_for_file: use_build_context_synchronously

import 'package:estate/screens/property/property_detail.dart';
import 'package:estate/services/exception/api_exception.dart';
import 'package:estate/services/property/property_service.dart';
import 'package:estate/services/user/user_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/property/property_card.dart';
import '../../widgets/search/filter_bottom_sheet.dart';
import '../../models/property.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({Key? key}) : super(key: key);

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final PropertyService _propertyService = PropertyService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _properties = [];
  List<dynamic> _filteredProperties = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  // Filtreler
  List<String>? _locations;
  List<RangeValues>? _priceRanges;
  bool? _superhost;

  // Filtre uygulandı mı kontrolü
  bool get _isFilterApplied =>
      _searchQuery.isNotEmpty ||
      (_locations != null && _locations!.isNotEmpty) ||
      (_priceRanges != null && _priceRanges!.isNotEmpty) ||
      _superhost != null;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final properties = await _propertyService.getProperties();

      setState(() {
        _properties = properties;
        _filteredProperties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is ApiException
            ? e.message
            : 'Mülkler yüklenirken bir hata oluştu';
        _isLoading = false;
      });
    }
  }

  void _searchProperties(String query) {
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
      bool? superhost}) {
    // Arama ve filtreleme için parametreleri güncelle
    if (locations != null) _locations = locations;
    if (priceRanges != null) _priceRanges = priceRanges;
    if (superhost != null) _superhost = superhost;

    setState(() {
      _filteredProperties = _properties.where((property) {
        // Arama sorgusu
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          final title = _normalizeText(property['title']?.toString() ?? '');
          final subtitle =
              _normalizeText(property['subtitle']?.toString() ?? '');
          final location =
              _normalizeText(property['location']?.toString() ?? '');
          final type =
              _normalizeText(property['propertyType']?.toString() ?? '');
          final normalizedQuery = _normalizeText(_searchQuery);

          matchesSearch = title.contains(normalizedQuery) ||
              subtitle.contains(normalizedQuery) ||
              location.contains(normalizedQuery) ||
              type.contains(normalizedQuery);
        }

        // Konum filtresi
        bool matchesLocation = true;
        if (_locations != null && _locations!.isNotEmpty) {
          final propertyLocation =
              _normalizeText(property['location']?.toString() ?? '');

          matchesLocation = _locations!.any((loc) {
            final normalizedLocation = _normalizeText(loc);
            return propertyLocation.contains(normalizedLocation);
          });
        }

        // Fiyat aralığı filtresi
        bool matchesPriceRange = true;
        if (_priceRanges != null && _priceRanges!.isNotEmpty) {
          final price = property['price'] is int
              ? property['price']
              : int.tryParse(property['price']
                      .toString()
                      .replaceAll(RegExp(r'[^0-9]'), '')) ??
                  0;

          // Herhangi bir fiyat aralığına uyuyorsa true döndür
          matchesPriceRange = _priceRanges!
              .any((range) => price >= range.start && price <= range.end);
        }

        // Superhost filtresi
        bool matchesSuperhost = true;
        if (_superhost != null && _superhost!) {
          matchesSuperhost = property['isSuperhost'] == true;
        }

        return matchesSearch &&
            matchesLocation &&
            matchesPriceRange &&
            matchesSuperhost;
      }).toList();
    });
  }

  // Tüm filtreleri temizle
  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _locations = null;
      _priceRanges = null;
      _superhost = null;
      _searchController.clear();
      _filteredProperties = _properties;
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
        onApplyFilters: (locations, priceRanges, superhost) {
          _applyFilters(
            locations: locations,
            priceRanges: priceRanges,
            superhost: superhost,
          );
        },
      ),
    );
  }

  Future<void> _togglePropertyFavorite(String propertyId) async {
    try {
      // Mülk favorilerden kaldırıldıysa, tekrar ekle
      final property =
          _filteredProperties.firstWhere((p) => p['_id'] == propertyId);
      final isSaved = property['isSaved'] ?? false;

      if (isSaved) {
        await _userService.removeSavedProperty(propertyId);
      } else {
        await _userService.saveProperty(propertyId);
      }

      // UI'ı güncelle
      setState(() {
        property['isSaved'] = !isSaved;

        // Aynı mülkü _properties listesinde de güncelle
        final originalProperty = _properties
            .firstWhere((p) => p['_id'] == propertyId, orElse: () => null);
        if (originalProperty != null) {
          originalProperty['isSaved'] = !isSaved;
        }
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
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(6),
            hintText: 'Konum, ev tipi ara...',
            border: InputBorder.none,
          ),
          onChanged: _searchProperties,
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
                          if (_superhost == true)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text('Superhost'),
                                backgroundColor: Color(0xFFE0E0E0),
                                labelStyle: TextStyle(fontSize: 12),
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
                              onPressed: _loadProperties,
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : _filteredProperties.isEmpty
                        ? const Center(child: Text('Sonuç bulunamadı'))
                        : RefreshIndicator(
                            onRefresh: _loadProperties,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredProperties.length,
                              itemBuilder: (context, index) {
                                final property = _filteredProperties[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: PropertyCard(
                                    property: Property.fromJson(property),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PropertyDetailScreen(
                                                  propertyId: property['_id']),
                                        ),
                                      );
                                    },
                                    onFavoriteToggle: () {
                                      _togglePropertyFavorite(property['_id']);
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
