import 'package:flutter/material.dart';

import '../snippets/snippets_screen.dart';
import '../../core/theme/app_colors.dart';
import '../snippets/add_snippet_screen.dart';
import '../profiles/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Sample dashboard data.
  // Favorites are currently stored in memory only.
  final List<Map<String, dynamic>> _recentSnippets = [
    {
      'title': 'Java HashMap',
      'language': 'Java',
      'category': 'Collections',
      'icon': Icons.data_object_rounded,
      'favorite': false,
    },
    {
      'title': 'Flutter Login UI',
      'language': 'Dart',
      'category': 'Authentication',
      'icon': Icons.phone_android_rounded,
      'favorite': false,
    },
    {
      'title': 'Python API Request',
      'language': 'Python',
      'category': 'API',
      'icon': Icons.api_rounded,
      'favorite': false,
    },
    {
      'title': 'React Component',
      'language': 'JavaScript',
      'category': 'Frontend',
      'icon': Icons.web_rounded,
      'favorite': false,
    },
  ];

  // Toggle the favorite state and immediately rebuild the UI.
  void _toggleFavorite(int index) {
    if (index < 0 || index >= _recentSnippets.length) {
      return;
    }

    late bool isFavorite;

    setState(() {
      final currentValue = _recentSnippets[index]['favorite'] as bool? ?? false;

      isFavorite = !currentValue;
      _recentSnippets[index]['favorite'] = isFavorite;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? '${_recentSnippets[index]['title']} added to favorites.'
                : '${_recentSnippets[index]['title']} removed from favorites.',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
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
        }
      });
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddSnippetScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
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

  // Display favorited dashboard snippets.
  void _showFavorites() {
    final favorites = _recentSnippets
        .where((snippet) => snippet['favorite'] == true)
        .toList();

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
                                    onPressed: () {
                                      final originalIndex = _recentSnippets
                                          .indexOf(snippet);

                                      Navigator.pop(sheetContext);

                                      if (originalIndex >= 0) {
                                        _toggleFavorite(originalIndex);
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
                        const Text(
                          'Good evening, Shrey 👋',
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
                        value: '24',
                        label: 'My Snippets',
                      ),
                      _buildStatCard(
                        icon: Icons.star_rounded,
                        value:
                            '${_recentSnippets.where((s) => s['favorite'] == true).length}',
                        label: 'Favorites',
                      ),
                      _buildStatCard(
                        icon: Icons.folder_outlined,
                        value: '6',
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
                    itemCount: _recentSnippets.length,
                    itemBuilder: (context, index) {
                      final snippet = _recentSnippets[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSnippetCard(
                          title: snippet['title'] as String,
                          language: snippet['language'] as String,
                          category: snippet['category'] as String,
                          icon: snippet['icon'] as IconData,
                          favorite: snippet['favorite'] as bool? ?? false,
                          onFavorite: () => _toggleFavorite(index),
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
}
