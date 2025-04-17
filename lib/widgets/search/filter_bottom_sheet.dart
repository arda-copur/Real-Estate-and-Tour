import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(List<String>?, List<RangeValues>?, bool?) onApplyFilters;
  final bool isExperience;

  const FilterBottomSheet({
    Key? key,
    required this.onApplyFilters,
    this.isExperience = false,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final List<String> _selectedLocations = [];
  final List<String> _selectedPriceRanges = [];
  bool? _isSuperhost;

  final List<String> _locations = [
    'İstanbul',
    'Antalya',
    'Bodrum',
    'Kapadokya',
    'Fethiye',
    'İzmir',
  ];

  final List<String> _priceRanges = [
    '0-100',
    '100-200',
    '200-300',
    '300-500',
    '500+',
  ];

  List<RangeValues>? _getPriceRangeValues(List<String>? rangeStrings) {
    if (rangeStrings == null || rangeStrings.isEmpty) return null;
    
    final List<RangeValues> result = [];
    
    for (final rangeString in rangeStrings) {
      if (rangeString == '500+') {
        result.add(const RangeValues(500, 10000));
        continue;
      }
      
      final parts = rangeString.split('-');
      if (parts.length == 2) {
        final min = double.tryParse(parts[0]);
        final max = double.tryParse(parts[1]);
        
        if (min != null && max != null) {
          result.add(RangeValues(min, max));
        }
      }
    }
    
    return result.isEmpty ? null : result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                widget.isExperience ? 'Deneyim Filtreleri' : 'Mülk Filtreleri',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedLocations.clear();
                    _selectedPriceRanges.clear();
                    _isSuperhost = null;
                  });
                },
                child: const Text('Temizle'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Konum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _locations.map((location) {
              return FilterChip(
                label: Text(location),
                selected: _selectedLocations.contains(location),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLocations.add(location);
                    } else {
                      _selectedLocations.remove(location);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fiyat Aralığı',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _priceRanges.map((range) {
              return FilterChip(
                label: Text(range),
                selected: _selectedPriceRanges.contains(range),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPriceRanges.add(range);
                    } else {
                      _selectedPriceRanges.remove(range);
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (!widget.isExperience) ...[  
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sadece Superhost'),
              value: _isSuperhost ?? false,
              onChanged: (value) {
                setState(() {
                  _isSuperhost = value;
                });
              },
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilters(
                  _selectedLocations.isEmpty ? null : _selectedLocations,
                  _selectedPriceRanges.isEmpty ? null : _getPriceRangeValues(_selectedPriceRanges),
                  widget.isExperience ? null : _isSuperhost,
                );
                Navigator.pop(context);
              },
              child: const Text('Filtreleri Uygula'),
            ),
          ),
        ],
      ),
    );
  }
}
