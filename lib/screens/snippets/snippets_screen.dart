import 'package:flutter/material.dart';

import 'add_snippet_screen.dart';
import 'snippet_details_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/firestore_service.dart';

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

  final List<Map<String, dynamic>> _snippets = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadSnippets();
  }

  Future<void> _loadSnippets() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final rawSnippets = await FirestoreService.getMySnippets();
      final favoriteIds = await FirestoreService.getFavoriteIds();
      if (!mounted) return;
      setState(() {
        _snippets
          ..clear()
          ..addAll(rawSnippets.map((snippet) => _toDisplaySnippet(
            snippet,
            favorite: favoriteIds.contains(snippet['id']?.toString()),
          )));
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _toDisplaySnippet(
    Map<String, dynamic> snippet, {
    bool favorite = false,
  }) {
    final tags = (snippet['tags'] as List<dynamic>? ?? const [])
        .map((tag) => tag.toString())
        .toList();
    final language = snippet['language']?.toString() ?? 'Other';
    return {
      ...snippet,
      'language': language,
      'category': tags.isEmpty ? 'Other' : tags.first,
      'description': snippet['description']?.toString() ?? '',
      'code': snippet['code']?.toString() ?? '',
      'icon': _iconForLanguage(language),
      'favorite': favorite,
    };
  }

  IconData _iconForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
      case 'flutter':
        return Icons.phone_android_rounded;
      case 'java':
      case 'kotlin':
        return Icons.data_object_rounded;
      case 'python':
        return Icons.bolt_rounded;
      case 'javascript':
        return Icons.web_rounded;
      default:
        return Icons.code_rounded;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSnippets {
    final query = _searchController.text.trim().toLowerCase();

    return _snippets.where((snippet) {
      final tags = (snippet['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString());
      final matchesCategory =
          _selectedCategory == 'All' ||
          snippet['category'] == _selectedCategory ||
          snippet['language'] == _selectedCategory ||
          tags.contains(_selectedCategory);

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

  Future<void> _openAddSnippet() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => const AddSnippetScreen(),
      ),
    );
    if (!mounted || result == null) return;
    try {
      final saved = await FirestoreService.createSnippet(
        title: result['title'] as String,
        code: result['code'] as String,
        language: result['language'] as String,
        description: result['description'] as String,
        tags: [result['category'] as String],
      );
      if (!mounted) return;
      setState(() {
        _snippets.insert(0, _toDisplaySnippet(saved));
        _selectedCategory = 'All';
        _searchController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Snippet saved to your ByteVault account.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save snippet: $error')),
      );
    }
  }

  Future<void> _toggleFavorite(int index) async {
    if (index < 0 || index >= _snippets.length) return;
    final snippet = _snippets[index];
    final id = snippet['id']?.toString();
    if (id == null || id.isEmpty) return;
    final wasFavorite = snippet['favorite'] as bool? ?? false;
    try {
      await FirestoreService.setFavorite(id, !wasFavorite);
      if (!mounted) return;
      setState(() => snippet['favorite'] = !wasFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasFavorite ? 'Removed from favorites' : 'Added to favorites'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update favorite: $error')),
      );
    }
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _loadError != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Could not load snippets: $_loadError',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: _loadSnippets,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Try again'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : snippets.isEmpty
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
