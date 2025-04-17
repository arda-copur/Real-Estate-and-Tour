import 'package:estate/widgets/custom/datepicker_widget.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom/guest_selector_widget.dart';
import '../../services/data/data_service.dart';
import '../../models/property.dart';
import '../../models/experience.dart';
import '../../models/destination.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DataService _dataService = DataService();
  List<Property> _searchedProperties = [];
  List<Experience> _searchedExperiences = [];
  bool _isSearching = false;
  late List<Destination> _destinations;

  @override
  void initState() {
    super.initState();
    _searchedProperties = [];
    _searchedExperiences = [];
    _destinations = _dataService.getDestinations();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchedProperties = [];
        _searchedExperiences = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchedProperties = _dataService.searchProperties(query);
      _searchedExperiences = _dataService.searchExperiences(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '"Costa Brava" ara',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
          autofocus: true,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildDefaultContent(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchedProperties.isEmpty && _searchedExperiences.isEmpty) {
      return const Center(
        child: Text('Sonuç bulunamadı'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchedProperties.isNotEmpty) ...[
            const Text(
              'Evler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchedProperties.length,
              itemBuilder: (context, index) {
                final property = _searchedProperties[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      property.images[0],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(property.title),
                  subtitle: Text(property.location),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/property_detail',
                      arguments: property,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          if (_searchedExperiences.isNotEmpty) ...[
            const Text(
              'Deneyimler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchedExperiences.length,
              itemBuilder: (context, index) {
                final experience = _searchedExperiences[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      experience.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(experience.title),
                  subtitle: Text(experience.location),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/experience_detail',
                      arguments: experience,
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const DatePickerWidget(
            startDate: '13 Mar',
            endDate: '16 Mar',
          ),
          const SizedBox(height: 16),
          const GuestSelectorWidget(
            guestCount: 2,
          ),
          const SizedBox(height: 24),
          const Text(
            'Popüler Destinasyonlar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                return _buildDestinationCard(
                  _destinations[index].name,
                  _destinations[index].image,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(String name, String image) {
    return GestureDetector(
      onTap: () {
        _searchController.text = name;
        _performSearch(name);
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
