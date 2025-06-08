import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vozvoz/core/services/location_service.dart';
import 'package:vozvoz/core/widgets/bottom_nav_bar.dart';
import 'package:vozvoz/core/widgets/location_permission_dialog.dart';
import 'package:vozvoz/features/prayer_times/data/services/prayer_times_service.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_times.dart';
import 'package:vozvoz/features/prayer_times/presentation/widgets/current_prayer_widget.dart';
import 'package:vozvoz/features/ayat_hadith/presentation/widgets/verse_hadith_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vozvoz/features/prayer_times/presentation/screens/prayer_times_screen.dart';
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
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      children: [
                        _buildHeader(),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1C6758),
                              ),
                            ),
                          )
                        else
                          _buildPrayerTimesCard(),
                        if (!_hasLocationError && !_isLoading) ...[
                          _buildDailyInspirationCard(),
                          const SizedBox(height: 16),
                          _buildDailyInspirationCard(),
                          const SizedBox(height: 16),
                          _buildDailyInspirationCard(),
                        ],
                      ],
                    ),
                  ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Namazio',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C6758),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF1C6758),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF1C6758),
              ),
              const SizedBox(width: 4),
              Text(
                _locationText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF1C6758),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesCard() {
    return GestureDetector(
      onTap: () => _handleNavigation(1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (_hasLocationError)
              _buildErrorState()
            else
              Column(
                children: [
                  _buildCurrentPrayerInfo(),
                  const SizedBox(height: 24),
                  _buildNextPrayerInfo(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPrayerInfo() {
    return Column(
      children: [
        Text(
          'Şu anki vakit',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _prayerTimes?.getCurrentPrayer() ?? '-',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C6758),
          ),
        ),
      ],
    );
  }

  Widget _buildNextPrayerInfo() {
    return Column(
      children: [
        Text(
          'Sonraki vakit',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _prayerTimes?.getNextPrayer() ?? '-',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C6758),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _prayerTimes?.getRemainingTime() ?? '-',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C6758),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
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
    );
  }

  Widget _buildDailyInspirationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günün Ayeti',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1C6758),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kim zerre miktarı hayır yapmışsa onu görür. Kim de zerre miktarı şer işlemişse onu görür.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Zilzal Suresi, 7-8',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
} 