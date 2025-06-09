import 'package:flutter/material.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuran-ı Kerim'),
        backgroundColor: const Color(0xFF1C6758),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Kuran-ı Kerim Sayfası'),
      ),
    );
  }
} 