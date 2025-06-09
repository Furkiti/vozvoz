import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_time.dart';
import 'package:vozvoz/features/prayer_times/presentation/providers/prayer_times_provider.dart';
import 'package:vozvoz/features/qibla/presentation/screens/qibla_screen.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C6758),
      body: Consumer<PrayerTimesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (provider.hasError) {
            return _buildErrorState(provider);
          }

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          children: [
                            _buildDateSection(context, provider),
                            const SizedBox(height: 24),
                            _buildNextPrayerCard(provider),
                            const SizedBox(height: 24),
                            _buildPrayerTimesList(provider.prayerTimesList),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(PrayerTimesProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Namaz vakitleri yüklenirken bir hata oluştu',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.refreshPrayerTimes(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1C6758),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
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

  Widget _buildDateSection(BuildContext context, PrayerTimesProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF1C6758),
                  size: 16,
                ),
                const SizedBox(width: 8),
                if (provider.prayerTimes != null)
                  Text(
                    provider.prayerTimes!.hijriDate,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF1C6758),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF1C6758),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  provider.locationText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF1C6758),
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QiblaScreen(),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1C6758).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.explore_outlined,
              color: Color(0xFF1C6758),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard(PrayerTimesProvider provider) {
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C6758),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Sonraki Vakit',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                nextPrayer.icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextPrayer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      nextPrayer.arabicName,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.remainingTime,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextPrayer.time,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(List<PrayerTime> prayerTimesList) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1C6758).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: prayerTimesList.length,
        separatorBuilder: (context, index) => Divider(
          color: const Color(0xFF1C6758).withOpacity(0.1),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final prayer = prayerTimesList[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: prayer.isActive
                  ? const Color(0xFF1C6758).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? const Radius.circular(24) : Radius.zero,
                bottom: index == prayerTimesList.length - 1
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
                        color: const Color(0xFF1C6758).withOpacity(0.6),
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
} 