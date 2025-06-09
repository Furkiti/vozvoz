import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vozvoz/core/services/location_service.dart';
import 'package:vozvoz/core/widgets/bottom_nav_bar.dart';
import 'package:vozvoz/features/prayer_times/data/services/prayer_times_service.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_times.dart';
import 'package:vozvoz/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:vozvoz/features/prayer_times/presentation/widgets/location_date_card.dart';
import 'package:vozvoz/features/prayer_times/presentation/widgets/prayer_info_card.dart';
import 'package:vozvoz/features/prayer_times/presentation/widgets/daily_ayah_card.dart';
import 'package:vozvoz/features/prayer_times/presentation/widgets/daily_hadith_card.dart';
import 'package:vozvoz/features/prayer_times/presentation/widgets/islamic_story_card.dart';
import 'package:vozvoz/core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final LocationService _locationService;
  late final PrayerTimesService _prayerTimesService;
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  String _locationText = 'Konum alınıyor...';
  bool _hasLocationError = false;
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _prayerTimesService = PrayerTimesService();
    _initializeLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoading = true;
        });

        // Şehir adını al
        final cityName = await _locationService.getAddressFromPosition(position);
        setState(() {
          _locationText = cityName;
        });

        // Konumu kaydet
        await _locationService.saveLastKnownLocation(position);
        
        // Namaz vakitlerini yükle
        await _loadPrayerTimes(position);
        
        // Konum stream'ini başlat
        _setupLocationStream();
      } else {
        _handleLocationError();
      }
    } catch (e) {
      debugPrint('Konum başlatma hatası: $e');
      _handleLocationError();
    }
  }

  Future<void> _handleLocationError() async {
    try {
      // Son bilinen konumu al
      final lastPosition = await _locationService.getLastKnownLocation();
      if (lastPosition != null) {
        setState(() {
          _currentPosition = lastPosition;
          _locationText = 'Son bilinen konum kullanılıyor';
          _hasLocationError = false;
        });
        await _loadPrayerTimes(lastPosition);
      } else {
        // Varsayılan konumu kullan
        final defaultPosition = Position(
          longitude: AppConstants.defaultLongitude,
          latitude: AppConstants.defaultLatitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        
        setState(() {
          _currentPosition = defaultPosition;
          _locationText = AppConstants.defaultCity;
          _hasLocationError = false;
        });
        await _loadPrayerTimes(defaultPosition);
      }
    } catch (e) {
      setState(() {
        _hasLocationError = true;
        _locationText = 'Konum alınamadı';
        _isLoading = false;
      });
    }
  }

  Future<void> _setupLocationStream() async {
    try {
      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        timeLimit: const Duration(minutes: 5),
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) async {
        final cityName = await _locationService.getAddressFromPosition(position);
        setState(() {
          _currentPosition = position;
          _locationText = cityName;
        });
        await _loadPrayerTimes(position);
      }, onError: (error) {
        debugPrint('Location stream error: $error');
      });
    } catch (e) {
      debugPrint('Error setting up location stream: $e');
    }
  }

  Future<void> _loadPrayerTimes(Position position) async {
    try {
      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      if (prayerTimes != null) {
        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
          _hasLocationError = false;
        });
      } else {
        setState(() {
          _hasLocationError = true;
          _locationText = 'Namaz vakitleri alınamadı';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Namaz vakitleri yükleme hatası: $e');
      setState(() {
        _hasLocationError = true;
        _locationText = 'Namaz vakitleri alınamadı';
        _isLoading = false;
      });
    }
  }

  void _handleNavigation(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrayerTimesScreen(currentIndex: index),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE6F4F1),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyHeaderDelegate(
                        child: LocationDateCard(
                          location: _locationText,
                          hijriDate: _prayerTimes?.hijriDate ?? '',
                          gregorianDate: _prayerTimes?.gregorianDate ?? '',
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1C6758),
                              ),
                            )
                          else if (_hasLocationError)
                            _buildErrorState()
                          else ...[
                            PrayerInfoCard(
                              currentPrayer: _prayerTimes?.getCurrentPrayer() ?? '',
                              currentPrayerTime: _prayerTimes?.getCurrentPrayerTime() ?? '',
                              currentPrayerArabic: _prayerTimes?.getCurrentPrayerArabic() ?? '',
                              nextPrayer: _prayerTimes?.getNextPrayer() ?? '',
                              nextPrayerTime: _prayerTimes?.getNextPrayerTime() ?? '',
                              nextPrayerArabic: _prayerTimes?.getNextPrayerArabic() ?? '',
                              remainingTime: _prayerTimes?.getRemainingTime() ?? '',
                            ),
                            const SizedBox(height: 24),
                            DailyAyahCard(
                              arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              translation: 'Rahman ve Rahim olan Allah\'ın adıyla',
                              source: 'Fatiha Suresi, 1. Ayet',
                              onShare: () {},
                            ),
                            const SizedBox(height: 24),
                            DailyHadithCard(
                              hadithText: 'Kolaylaştırınız, zorlaştırmayınız. Müjdeleyiniz, nefret ettirmeyiniz.',
                              source: 'Buhârî, İlim, 11',
                              onShare: () {},
                            ),
                            const SizedBox(height: 24),
                            IslamicStoryCard(
                              title: 'Hz. Mevlana\'nın Sabır Hikayesi',
                              content: 'Bir gün Hz. Mevlana\'ya bir derviş geldi ve "Efendim" dedi, "ben sabrın ne olduğunu bilmiyorum. Bana sabrı öğretir misiniz?"...',
                              onReadMore: () {},
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: Text('Diğer sayfalar yapım aşamasında')),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.all(
              GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        child: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleNavigation,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.location_off,
            size: 48,
            color: Color(0xFF1C6758),
          ),
          const SizedBox(height: 16),
          Text(
            'Konum bilgisi alınamadı',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C6758),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Namaz vakitlerini görebilmek için konum izni gerekiyor',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C6758),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Tekrar Dene',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
} 