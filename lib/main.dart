import 'package:flutter/material.dart';

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
      home: const PolkaHomePage(),
    );
  }
}

class PolkaHomePage extends StatelessWidget {
  const PolkaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Полка')),
      body: const Center(child: Text('Полка', style: TextStyle(fontSize: 24))),
    );
  }
}
