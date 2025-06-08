import 'package:flutter/material.dart';
import 'package:vozvoz/features/prayer_times/presentation/screens/home_screen.dart';

class AppRouter {
  static final router = MaterialApp(
    home: const HomeScreen(),
    routes: {
      '/': (context) => const HomeScreen(),
      '/prayer-times': (context) => const Scaffold(body: Center(child: Text('Prayer Times Screen'))),
      '/qibla': (context) => const Scaffold(body: Center(child: Text('Qibla Screen'))),
      '/dhikr': (context) => const Scaffold(body: Center(child: Text('Dhikr Screen'))),
      '/ayat-hadith': (context) => const Scaffold(body: Center(child: Text('Ayat & Hadith Screen'))),
      '/settings': (context) => const Scaffold(body: Center(child: Text('Settings Screen'))),
    },
  );
} 