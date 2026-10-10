import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

import '../../core/theme/app_colors.dart';

class AddSnippetScreen extends StatefulWidget {
  const AddSnippetScreen({super.key});

  @override
  State<AddSnippetScreen> createState() => _AddSnippetScreenState();
}

class _AddSnippetScreenState extends State<AddSnippetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();

  String _selectedLanguage = 'Dart';
  String _selectedCategory = 'Flutter';

  final List<String> _languages = [
    'Dart',
    'Java',
    'Python',
    'JavaScript',
    'C++',
    'C',
    'Kotlin',
    'Other',
  ];

  final List<String> _categories = [
    'Flutter',
    'Authentication',
    'API',
    'Database',
    'UI/UX',
    'Algorithms',
    'Collections',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get _highlightLanguage {
    switch (_selectedLanguage) {
      case 'Dart':
        return 'dart';
      case 'Java':
        return 'java';
      case 'Python':
        return 'python';
      case 'JavaScript':
        return 'javascript';
      case 'C++':
        return 'cpp';
      case 'C':
        return 'c';
      case 'Kotlin':
        return 'kotlin';
      default:
        return 'plaintext';
    }
  }

  // Validate the form and return the new snippet to the previous screen.
  void _saveSnippet() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final snippet = <String, dynamic>{
      'title': _titleController.text.trim(),
      'language': _selectedLanguage,
      'category': _selectedCategory,
      'description': _descriptionController.text.trim(),
      'code': _codeController.text.trim(),
      'icon': Icons.code_rounded,
      'favorite': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    Navigator.pop(context, snippet);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final contentWidth = isDesktop ? 760.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          tooltip: 'Go back',
        ),
        title: const Text(
          'Add New Snippet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            child: SizedBox(
              width: contentWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create a new snippet',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Save useful pieces of code to your personal vault.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Snippet Title', required: true),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Firebase Auth Login',
                              prefixIcon: Icon(Icons.title_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a snippet title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          if (isDesktop)
                            Row(
                              children: [
                                Expanded(child: _buildLanguageDropdown()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildCategoryDropdown()),
                              ],
                            )
                          else ...[
                            _buildLanguageDropdown(),
                            const SizedBox(height: 20),
                            _buildCategoryDropdown(),
                          ],
                          const SizedBox(height: 22),
                          _buildLabel('Description', required: true),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Describe what this snippet does...',
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 58),
                                child: Icon(Icons.description_outlined),
                              ),
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please add a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          _buildLabel('Code', required: true),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _codeController,
                            maxLines: 12,
                            minLines: 8,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '// Paste your code here',
                              hintStyle: TextStyle(
                                fontFamily: 'monospace',
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: AppColors.codeBackground,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 170),
                                child: Icon(Icons.code_rounded),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('Live Syntax Preview'),
                          const SizedBox(height: 8),
                          _buildSyntaxPreview(),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _saveSnippet,
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('SAVE SNIPPET'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlush,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your code is highlighted live as you type. '
                              'This version passes new snippets back to the '
                              'list in memory; permanent storage is not '
                              'connected yet.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyntaxPreview() {
    final code = _codeController.text;

    if (code.trim().isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.codeBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Your highlighted code will appear here as you type.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary.withValues(alpha: 0.9),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: HighlightView(
            code,
            language: _highlightLanguage,
            theme: githubTheme,
            padding: EdgeInsets.zero,
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Programming Language', required: true),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedLanguage,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.code_rounded),
          ),
          items: _languages.map((language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(language),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedLanguage = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Category', required: true),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.folder_outlined),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }
}
