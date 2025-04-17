import 'package:flutter/material.dart';
import '../../models/help_category.dart';
import '../../services/data/data_service.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final DataService _dataService = DataService();
  late List<HelpCategory> _helpCategories;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _helpCategories = _dataService.getHelpCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım Merkezi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Yardım konusu ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildCategoryList()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _helpCategories.length,
      itemBuilder: (context, index) {
        final category = _helpCategories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(category.icon, color: const Color(0xFFFF5A5F)),
            title: Text(
              category.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showArticlesList(category);
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    // Tüm makaleleri düzleştir ve arama yap
    List<Map<String, dynamic>> allArticles = [];

    for (var category in _helpCategories) {
      for (var article in category.articles) {
        if (article.toLowerCase().contains(_searchQuery.toLowerCase())) {
          allArticles.add({
            'category': category.title,
            'article': article,
          });
        }
      }
    }

    if (allArticles.isEmpty) {
      return const Center(
        child: Text('Sonuç bulunamadı'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allArticles.length,
      itemBuilder: (context, index) {
        final article = allArticles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(article['article']),
            subtitle: Text(article['category']),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showArticleDetail(article['article']);
            },
          ),
        );
      },
    );
  }

  void _showArticlesList(HelpCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: category.articles.length,
                    itemBuilder: (context, index) {
                      final article = category.articles[index];
                      return ListTile(
                        title: Text(article),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context);
                          _showArticleDetail(article);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showArticleDetail(String article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(article),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Siz değerli kullanıcılarımıza yardımcı olabilmek için iletişim merkezimiz 7/24 çalışmaktadır.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lütfen bir sorun yaşıyorsanız önce destek talebi yollayın. Destek talebini inceleyip yanıtımızı bildirdikten sonra, sorun hala çözülmezse iletişim merkezimizden bizlere ulaşabilirsiniz.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bu makale yardımcı oldu mu?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Geri bildiriminiz için teşekkürler!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.thumb_up),
                      label: const Text('Evet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Geri bildiriminiz için teşekkürler!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.thumb_down),
                      label: const Text('Hayır'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
