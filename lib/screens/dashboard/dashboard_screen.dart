import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../snippets/snippets_screen.dart';
import '../../core/theme/app_colors.dart';
import '../snippets/add_snippet_screen.dart';
import '../profiles/profile_screen.dart';
import '../../core/services/firestore_service.dart';
import '../snippets/snippet_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _allSnippets = [];
  List<Map<String, dynamic>> _recentSnippets = [];
  List<Map<String, dynamic>> _favoriteSnippets = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final rawSnippets = await FirestoreService.getMySnippets();
      final rawFavorites = await FirestoreService.getFavorites();
      final stats = await FirestoreService.getDashboardStats();
      final favoriteIds = rawFavorites
          .map((item) => item['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final allSnippets = rawSnippets
          .map((item) => _toDisplaySnippet(
                item,
                favorite: favoriteIds.contains(item['id']?.toString()),
              ))
          .toList();
      final favorites = rawFavorites
          .map((item) => _toDisplaySnippet(item, favorite: true))
          .toList();
      if (!mounted) return;
      setState(() {
        _allSnippets = allSnippets;
        _recentSnippets = allSnippets.take(4).toList();
        _favoriteSnippets = favorites;
        _stats = stats;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString();
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
      'icon': _languageIcon(language),
      'favorite': favorite,
    };
  }

  IconData _languageIcon(String language) {
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

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  int get _categoryCount => _allSnippets
      .map((item) => item['category']?.toString())
      .where((category) => category != null && category.isNotEmpty)
      .toSet()
      .length;

  Future<void> _toggleFavorite(int index) async {
    if (index < 0 || index >= _recentSnippets.length) return;
    final snippet = _recentSnippets[index];
    final id = snippet['id']?.toString();
    if (id == null || id.isEmpty) return;
    final wasFavorite = snippet['favorite'] as bool? ?? false;
    try {
      await FirestoreService.setFavorite(id, !wasFavorite);
      await _loadDashboard(showLoading: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasFavorite ? 'Removed from favorites.' : 'Added to favorites.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update favorite: $error')),
      );
    }
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
      await FirestoreService.createSnippet(
        title: result['title'] as String,
        code: result['code'] as String,
        language: result['language'] as String,
        description: result['description'] as String,
        tags: [result['category'] as String],
      );
      await _loadDashboard(showLoading: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Snippet saved to your account.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save snippet: $error')),
      );
    }
  }

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SnippetsScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
          _loadDashboard(showLoading: false);
        }
      });
      return;
    }

    if (index == 2) {
      _openAddSnippet();
      return;
    }

    if (index == 3) {
      _showFavorites();
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
      return;
    }
  }

  // Display the signed-in user's favorites returned by the backend.
  void _showFavorites() {
    final favorites = _favoriteSnippets;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Favorites',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: favorites.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_border_rounded,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No favorites yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Tap a star on a snippet to save it here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: favorites.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final snippet = favorites[index];

                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    snippet['icon'] as IconData,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    snippet['title'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${snippet['language']} • ${snippet['category']}',
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Remove from favorites',
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final id = snippet['id']?.toString();
                                      Navigator.pop(sheetContext);
                                      if (id == null || id.isEmpty) return;
                                      try {
                                        await FirestoreService.setFavorite(id, false);
                                        await _loadDashboard(showLoading: false);
                                      } catch (error) {
                                        if (!mounted) return;
                                        messenger.showSnackBar(
                                          SnackBar(content: Text('Could not remove favorite: $error')),
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: CustomScrollView(
              slivers: [
                // TOP BAR
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32 : 20,
                      22,
                      isDesktop ? 32 : 20,
                      0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.code_rounded,
                            color: AppColors.white,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'CodeSnippet Vault',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Notifications',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No new notifications.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_none_rounded),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceBlush,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // WELCOME SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32 : 20,
                      34,
                      isDesktop ? 32 : 20,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good evening, $_displayName 👋',
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Your code library at a glance.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Search opens the snippets screen.
                        TextField(
                          readOnly: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SnippetsScreen(),
                              ),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search your snippets...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceBlush,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                size: 19,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // STAT CARDS
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate([
                      _buildStatCard(
                        icon: Icons.code_rounded,
                        value: _isLoading
                            ? '…'
                            : '${_stats['snippetCount'] ?? _allSnippets.length}',
                        label: 'My Snippets',
                      ),
                      _buildStatCard(
                        icon: Icons.star_rounded,
                        value: _isLoading
                            ? '…'
                            : '${_stats['favoriteCount'] ?? _favoriteSnippets.length}',
                        label: 'Favorites',
                      ),
                      _buildStatCard(
                        icon: Icons.folder_outlined,
                        value: _isLoading ? '…' : '$_categoryCount',
                        label: 'Categories',
                      ),
                    ]),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 1,
                      mainAxisExtent: 105,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                  ),
                ),

                // RECENT SNIPPETS HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32 : 20,
                      34,
                      isDesktop ? 32 : 20,
                      14,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Recent Snippets',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SnippetsScreen(),
                              ),
                            );
                          },
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                  ),
                ),

                // SNIPPET LIST
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 32 : 20,
                    0,
                    isDesktop ? 32 : 20,
                    120,
                  ),
                  sliver: SliverList.builder(
                    itemCount: _recentSnippets.isEmpty ? 1 : _recentSnippets.length,
                    itemBuilder: (context, index) {
                      if (_recentSnippets.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            _isLoading
                                ? 'Loading your snippets…'
                                : _loadError ?? 'No snippets yet. Add your first one.',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      final snippet = _recentSnippets[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openSnippetDetails(snippet),
                          child: _buildSnippetCard(
                          title: snippet['title'] as String,
                          language: snippet['language'] as String,
                          category: snippet['category'] as String,
                          icon: snippet['icon'] as IconData,
                          favorite: snippet['favorite'] as bool? ?? false,
                          onFavorite: () => _toggleFavorite(index),
                          ),
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

      // BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavigationTap,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.surfaceBlush,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border_rounded),
            selectedIcon: Icon(Icons.star_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceBlush,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnippetCard({
    required String title,
    required String language,
    required String category,
    required IconData icon,
    required bool favorite,
    required VoidCallback onFavorite,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$language • $category',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // The star now responds to the favorite state.
          IconButton(
            tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: onFavorite,
            icon: Icon(
              favorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: favorite ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openSnippetDetails(Map<String, dynamic> snippet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SnippetDetailsScreen(
          title: snippet['title']?.toString() ?? 'Untitled',
          language: snippet['language']?.toString() ?? 'Other',
          category: snippet['category']?.toString() ?? 'Other',
          description: snippet['description']?.toString() ?? '',
          code: snippet['code']?.toString() ?? '',
        ),
      ),
    );
  }
}
