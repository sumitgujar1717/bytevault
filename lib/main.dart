import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const CodeSnippetVault());
}

class CodeSnippetVault extends StatelessWidget {
  const CodeSnippetVault({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeSnippet Vault',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
