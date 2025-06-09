import 'package:flutter/material.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble'),
        backgroundColor: const Color(0xFF1C6758),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Kıble Pusulası'),
      ),
    );
  }
} 