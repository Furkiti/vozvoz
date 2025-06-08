import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vozvoz/core/widgets/bottom_nav_bar.dart';
import 'package:vozvoz/core/services/location_service.dart';
import 'package:vozvoz/features/prayer_times/data/services/prayer_times_service.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_time.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_times.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:vozvoz/core/constants/app_constants.dart';

class PrayerTimesScreen extends StatefulWidget {
  final int currentIndex;
  
  const PrayerTimesScreen({
    super.key,
    this.currentIndex = 1,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _locationService = LocationService();
  final _prayerTimesService = PrayerTimesService();
  
  String _locationText = 'Konum alınıyor...';
  bool _isLoading = true;
  bool _hasError = false;
  Position? _currentPosition;
  PrayerTimes? _prayerTimes;
  List<PrayerTime> _prayerTimesList = [];
  String _hijriDate = '';
  String _gregorianDate = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Konum al
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
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
        
        _currentPosition = defaultPosition;
        _locationText = AppConstants.defaultCity;
        
        // Namaz vakitlerini al
        await _loadPrayerTimes(defaultPosition);
        return;
      }

      _currentPosition = position;
      
      // Şehir adını al
      final cityName = await _locationService.getAddressFromPosition(position);
      setState(() {
        _locationText = cityName;
      });

      // Namaz vakitlerini al
      await _loadPrayerTimes(position);
    } catch (e) {
      debugPrint('Veri başlatılırken hata: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
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
          _prayerTimesList = [
            PrayerTime(
              name: "İmsak",
              arabicName: "الفجر",
              time: prayerTimes.fajr,
              icon: Icons.nights_stay,
              isActive: prayerTimes.getCurrentPrayer() == "İmsak",
            ),
            PrayerTime(
              name: "Güneş",
              arabicName: "الشروق",
              time: prayerTimes.sunrise,
              icon: Icons.wb_twilight,
              isActive: false,
            ),
            PrayerTime(
              name: "Öğle",
              arabicName: "الظهر",
              time: prayerTimes.dhuhr,
              icon: Icons.wb_sunny,
              isActive: prayerTimes.getCurrentPrayer() == "Öğle",
            ),
            PrayerTime(
              name: "İkindi",
              arabicName: "العصر",
              time: prayerTimes.asr,
              icon: Icons.sunny_snowing,
              isActive: prayerTimes.getCurrentPrayer() == "İkindi",
            ),
            PrayerTime(
              name: "Akşam",
              arabicName: "المغرب",
              time: prayerTimes.maghrib,
              icon: Icons.nights_stay_outlined,
              isActive: prayerTimes.getCurrentPrayer() == "Akşam",
            ),
            PrayerTime(
              name: "Yatsı",
              arabicName: "العشاء",
              time: prayerTimes.isha,
              icon: Icons.dark_mode,
              isActive: prayerTimes.getCurrentPrayer() == "Yatsı",
            ),
          ];

          // Tarihleri ayarla
          final now = DateTime.now();
          _gregorianDate = DateFormat('d MMMM yyyy', 'tr_TR').format(now);
          _hijriDate = prayerTimes.hijriDate;
          _hasError = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Namaz vakitleri yüklenirken hata: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C6758),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1C6758),
              const Color(0xFF1C6758).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : _hasError
                  ? _buildErrorState()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildHeader(context),
                          _buildDateSection(),
                          const SizedBox(height: 24),
                          _buildNextPrayerCard(),
                          const SizedBox(height: 24),
                          _buildPrayerTimesList(),
                          const SizedBox(height: 24),
                          if (_prayerTimes != null) _buildCountdownWidget(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        ),
      ),
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
          currentIndex: widget.currentIndex,
          onTap: (index) {
            if (index != widget.currentIndex) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Namaz vakitleri yüklenemedi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen internet bağlantınızı kontrol edin\nve tekrar deneyin',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1C6758),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: Text(
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Text(
            'Namaz Vakitleri',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _hijriDate,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _locationText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    final nextPrayer = _prayerTimesList.firstWhere(
      (prayer) => prayer.isActive,
      orElse: () => _prayerTimesList.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Sonraki Vakit',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                nextPrayer.icon,
                size: 32,
                color: const Color(0xFF1C6758),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextPrayer.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1C6758),
                    ),
                  ),
                  Text(
                    nextPrayer.arabicName,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                nextPrayer.time,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C6758),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _prayerTimesList.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[200],
          height: 1,
        ),
        itemBuilder: (context, index) {
          final prayer = _prayerTimesList[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: prayer.isActive
                  ? const Color(0xFF1C6758).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? const Radius.circular(24) : Radius.zero,
                bottom: index == _prayerTimesList.length - 1
                    ? const Radius.circular(24)
                    : Radius.zero,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  prayer.icon,
                  color: const Color(0xFF1C6758),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight:
                            prayer.isActive ? FontWeight.bold : FontWeight.normal,
                        color: const Color(0xFF1C6758),
                      ),
                    ),
                    Text(
                      prayer.arabicName,
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  prayer.time,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight:
                        prayer.isActive ? FontWeight.bold : FontWeight.normal,
                    color: const Color(0xFF1C6758),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountdownWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_prayerTimes!.getNextPrayer()} vaktine kalan süre: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Text(
            _prayerTimes!.getRemainingTime(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeCard({
    required String title,
    required String time,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1C6758) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 