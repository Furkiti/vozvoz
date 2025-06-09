import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:vozvoz/core/di/injection.dart';
import 'package:vozvoz/core/theme/app_theme.dart';
import 'package:vozvoz/features/prayer_times/presentation/providers/prayer_times_provider.dart';
import 'package:vozvoz/features/prayer_times/presentation/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<PrayerTimesProvider>(),
      child: MaterialApp(
        title: 'Vozvoz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'US'),
        ],
        home: const HomeScreen(),
        routes: {
          '/prayer-times': (context) => const Scaffold(body: Center(child: Text('Prayer Times Screen'))),
          '/qibla': (context) => const Scaffold(body: Center(child: Text('Qibla Screen'))),
          '/dhikr': (context) => const Scaffold(body: Center(child: Text('Dhikr Screen'))),
          '/ayat-hadith': (context) => const Scaffold(body: Center(child: Text('Ayat & Hadith Screen'))),
          '/settings': (context) => const Scaffold(body: Center(child: Text('Settings Screen'))),
        },
      ),
    );
  }
}
