import 'package:flutter/material.dart';

import 'add_snippet_screen.dart';
import 'snippet_details_screen.dart';
import '../../core/theme/app_colors.dart';

class SnippetsScreen extends StatefulWidget {
  const SnippetsScreen({super.key});

  @override
  State<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends State<SnippetsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Flutter',
    'Dart',
    'Java',
    'Python',
    'JavaScript',
    'Other',
  ];

  // Demo snippets. New snippets are added to this list.
  final List<Map<String, dynamic>> _snippets = [
    {
      'title': 'Java HashMap',
      'language': 'Java',
      'category': 'Java',
      'description': 'Working with HashMap collections in Java.',
      'icon': Icons.data_object_rounded,
      'favorite': true,
      'code': '''import java.util.HashMap;

public class Main {
  public static void main(String[] args) {
    HashMap<String, Integer> scores = new HashMap<>();
    scores.put("Alex", 95);
    System.out.println(scores.get("Alex"));
  }
}''',
    },
    {
      'title': 'Flutter Login UI',
      'language': 'Dart',
      'category': 'Flutter',
      'description': 'Reusable Flutter login screen with form validation.',
      'icon': Icons.phone_android_rounded,
      'favorite': false,
      'code': '''import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}''',
    },
    {
      'title': 'Python API Request',
      'language': 'Python',
      'category': 'Python',
      'description': 'Make a GET request using Python HTTP libraries.',
      'icon': Icons.api_rounded,
      'favorite': true,
      'code': '''import urllib.request
import json

url = "https://jsonplaceholder.typicode.com/todos/1"

with urllib.request.urlopen(url) as response:
    data = json.loads(response.read().decode())

print(data)''',
    },
    {
      'title': 'React Component',
      'language': 'JavaScript',
      'category': 'JavaScript',
      'description': 'Basic reusable React functional component.',
      'icon': Icons.web_rounded,
      'favorite': false,
      'code': '''import React from "react";

function Welcome() {
  return (
    <div>
      <h1>Hello, world!</h1>
      <p>Welcome to my app.</p>
    </div>
  );
}

export default Welcome;''',
    },
    {
      'title': 'Flutter Navigation',
      'language': 'Dart',
      'category': 'Flutter',
      'description': 'Navigate between screens using Flutter routes.',
      'icon': Icons.navigation_rounded,
      'favorite': false,
      'code': '''Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DetailsScreen(),
  ),
);''',
    },
    {
      'title': 'Dart Async Function',
      'language': 'Dart',
      'category': 'Dart',
      'description': 'Simple async and await example in Dart.',
      'icon': Icons.bolt_rounded,
      'favorite': false,
      'code': '''Future<String> fetchMessage() async {
  await Future.delayed(
    const Duration(seconds: 1),
  );
  return 'Hello from async Dart!';
}

void main() async {
  final message = await fetchMessage();
  print(message);
}''',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSnippets {
    final query = _searchController.text.trim().toLowerCase();

    return _snippets.where((snippet) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          snippet['category'] == _selectedCategory;

      final matchesSearch =
          query.isEmpty ||
          snippet['title'].toString().toLowerCase().contains(query) ||
          snippet['language'].toString().toLowerCase().contains(query) ||
          snippet['category'].toString().toLowerCase().contains(query) ||
          snippet['description'].toString().toLowerCase().contains(query) ||
          snippet['code'].toString().toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Receive the snippet returned by AddSnippetScreen.
  Future<void> _openAddSnippet() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => const AddSnippetScreen(),
      ),
    );

    if (!mounted || result == null) return;

    final newSnippet = <String, dynamic>{
      ...result,
      'icon': Icons.code_rounded,
      'favorite': false,
    };

    setState(() {
      _snippets.insert(0, newSnippet);
      _selectedCategory = 'All';
      _searchController.clear();
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Snippet added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _toggleFavorite(int index) {
    if (index < 0 || index >= _snippets.length) return;

    setState(() {
      _snippets[index]['favorite'] = !(_snippets[index]['favorite'] as bool);
    });

    final isFavorite = _snippets[index]['favorite'] as bool;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _openSnippetDetails(Map<String, dynamic> snippet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SnippetDetailsScreen(
          title: snippet['title'] as String,
          language: snippet['language'] as String,
          category: snippet['category'] as String,
          description: snippet['description'] as String,
          code: snippet['code'] as String,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final snippets = _filteredSnippets;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 32 : 20,
                    22,
                    isDesktop ? 32 : 20,
                    10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.textPrimary,
                        tooltip: 'Go back',
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Snippets',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Your personal code collection',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Add snippet',
                        onPressed: _openAddSnippet,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                // Search
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                    vertical: 12,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search snippets...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear_rounded),
                              tooltip: 'Clear search',
                            )
                          : null,
                    ),
                  ),
                ),

                // Category filters
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Result count
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${snippets.length} snippets',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Snippet list
                Expanded(
                  child: snippets.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            isDesktop ? 32 : 20,
                            0,
                            isDesktop ? 32 : 20,
                            100,
                          ),
                          itemCount: snippets.length,
                          itemBuilder: (context, index) {
                            final snippet = snippets[index];
                            final originalIndex = _snippets.indexOf(snippet);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSnippetCard(
                                title: snippet['title'] as String,
                                language: snippet['language'] as String,
                                category: snippet['category'] as String,
                                description: snippet['description'] as String,
                                icon: snippet['icon'] as IconData,
                                favorite: snippet['favorite'] as bool,
                                onFavorite: () {
                                  _toggleFavorite(originalIndex);
                                },
                                onTap: () {
                                  _openSnippetDetails(snippet);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSnippet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Snippet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSnippetCard({
    required String title,
    required String language,
    required String category,
    required String description,
    required IconData icon,
    required bool favorite,
    required VoidCallback onFavorite,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBlush,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$language • $category',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap to view code',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: favorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: onFavorite,
                icon: Icon(
                  favorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: favorite ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceBlush,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No snippets found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Try a different search or category.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
