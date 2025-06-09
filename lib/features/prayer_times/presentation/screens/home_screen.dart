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
import 'package:provider/provider.dart';
import 'package:vozvoz/features/prayer_times/presentation/providers/prayer_times_provider.dart';
import 'package:vozvoz/features/quran/presentation/providers/quran_provider.dart';
import 'package:vozvoz/features/quran/presentation/screens/quran_screen.dart';
import 'package:vozvoz/features/settings/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const PrayerTimesScreen(),
    const QuranScreen(),
    const SettingsScreen(),
  ];

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C6758),
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
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
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Location and Date Header
                _buildLocationHeader(provider),
                const SizedBox(height: 16),
                // Current Prayer Time Card
                _buildCurrentPrayerCard(provider),
                const SizedBox(height: 16),
                // Daily Verse Card
                _buildDailyVerseCard(),
                const SizedBox(height: 16),
                // Daily Hadith Card
                _buildDailyHadithCard(),
                const SizedBox(height: 16),
                // Islamic Story Card
                _buildIslamicStoryCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationHeader(PrayerTimesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Location Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  provider.locationText,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (provider.prayerTimes != null) ...[
            const SizedBox(height: 8),
            Text(
              provider.prayerTimes!.gregorianDate,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.hijriDate,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            // Local Time Widget
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Yerel Saat: ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      provider.localTime,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentPrayerCard(PrayerTimesProvider provider) {
    if (provider.prayerTimes == null) return const SizedBox.shrink();

    final currentPrayer = provider.prayerTimesList.firstWhere(
      (prayer) => prayer.isActive,
      orElse: () => provider.prayerTimesList.first,
    );

    final currentIndex = provider.prayerTimesList.indexOf(currentPrayer);
    final nextPrayer = currentIndex < provider.prayerTimesList.length - 1
        ? provider.prayerTimesList[currentIndex + 1]
        : provider.prayerTimesList.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A8171),
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
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Şu anki vakit',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentPrayer.icon,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${currentPrayer.name} - ${currentPrayer.time}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  currentPrayer.arabicName,
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Next Prayer Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  'Sonraki vakit',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          nextPrayer.icon,
                          color: const Color(0xFF1C6758),
                          size: 32,
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
                      ],
                    ),
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C6758).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.remainingTime,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1C6758),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyVerseCard() {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, child) {
        final dailyVerse = quranProvider.getDailyVerse();
        if (dailyVerse == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/quran');
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Günün Ayeti',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C6758),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.share,
                        color: Color(0xFF1C6758),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  dailyVerse.arabicText,
                  style: GoogleFonts.amiri(
                    fontSize: 32,
                    color: const Color(0xFF1C6758),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  dailyVerse.turkishText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C6758).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dailyVerse.surahName}, ${dailyVerse.verseNumber}. Ayet',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF1C6758),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tüm ayetleri görüntüle',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF1C6758),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF1C6758),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyHadithCard() {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, child) {
        final dailyHadith = quranProvider.getDailyHadith();
        if (dailyHadith == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4F1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Günün Hadisi',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C6758),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.share,
                      color: Color(0xFF1C6758),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                dailyHadith.text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C6758).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dailyHadith.source,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF1C6758),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIslamicStoryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1C6758).withOpacity(0.1),
            const Color(0xFF1C6758).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günün Hikayesi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C6758),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  color: Color(0xFF1C6758),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Hz. Mevlana\'nın Sabır Hikayesi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C6758),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bir gün Hz. Mevlana\'ya bir derviş geldi ve "Efendim" dedi, "ben sabrın ne olduğunu bilmiyorum. Bana sabrı öğretir misiniz?"...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C6758).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1C6758),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Devamını Oku',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
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