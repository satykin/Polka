import 'package:flutter/material.dart';
import 'package:polka/core/theme/app_theme.dart';
import 'package:polka/features/cosmetics/presentation/cosmetics_list_screen.dart';

void main() {
  runApp(const PolkaApp());
}

class PolkaApp extends StatelessWidget {
  const PolkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Полка',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const CosmeticsListScreen(),
    );
  }
}
