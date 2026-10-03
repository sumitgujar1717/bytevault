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

  final List<Map<String, dynamic>> _recentSnippets = [
    {
      'title': 'Java HashMap',
      'language': 'Java',
      'category': 'Collections',
      'icon': Icons.data_object_rounded,
    },
    {
      'title': 'Flutter Login UI',
      'language': 'Dart',
      'category': 'Authentication',
      'icon': Icons.phone_android_rounded,
    },
    {
      'title': 'Python API Request',
      'language': 'Python',
      'category': 'API',
      'icon': Icons.api_rounded,
    },
    {
      'title': 'React Component',
      'language': 'JavaScript',
      'category': 'Frontend',
      'icon': Icons.web_rounded,
    },
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SnippetsScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddSnippetScreen()),
      );
      return;
    }

    if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorites screen will be available soon.'),
        ),
      );
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }
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
                // -----------------------------------------------
                // TOP BAR
                // -----------------------------------------------
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

                // -----------------------------------------------
                // WELCOME SECTION
                // -----------------------------------------------
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

                        // Search
                        TextField(
                          readOnly: true,

                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Search will be available soon.'),
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

                // -----------------------------------------------
                // STAT CARDS
                // -----------------------------------------------
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
                        value: '8',
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

                // -----------------------------------------------
                // RECENT SNIPPETS HEADER
                // -----------------------------------------------
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'All snippets will be available soon.',
                                ),
                              ),
                            );
                          },

                          child: const Text('View all'),
                        ),
                      ],
                    ),
                  ),
                ),

                // -----------------------------------------------
                // SNIPPET LIST
                // -----------------------------------------------
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

      // -----------------------------------------------
      // BOTTOM NAVIGATION
      // -----------------------------------------------
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

          IconButton(
            tooltip: 'Favorite',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title added to favorites.')),
              );
            },
            icon: const Icon(
              Icons.star_border_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
