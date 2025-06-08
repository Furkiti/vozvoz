import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vozvoz/features/prayer_times/presentation/screens/home_screen.dart';
import 'package:vozvoz/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Türkçe tarih formatlamasını başlat
  await initializeDateFormatting('tr_TR', null);
  
  // Dikey yönlendirmeyi zorla
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vozvoz',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      routes: {
        '/prayer-times': (context) => const Scaffold(body: Center(child: Text('Prayer Times Screen'))),
        '/qibla': (context) => const Scaffold(body: Center(child: Text('Qibla Screen'))),
        '/dhikr': (context) => const Scaffold(body: Center(child: Text('Dhikr Screen'))),
        '/ayat-hadith': (context) => const Scaffold(body: Center(child: Text('Ayat & Hadith Screen'))),
        '/settings': (context) => const Scaffold(body: Center(child: Text('Settings Screen'))),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
