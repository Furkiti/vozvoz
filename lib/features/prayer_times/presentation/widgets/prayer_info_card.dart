import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrayerInfoCard extends StatelessWidget {
  final String currentPrayer;
  final String currentPrayerTime;
  final String currentPrayerArabic;
  final String nextPrayer;
  final String nextPrayerTime;
  final String nextPrayerArabic;
  final String remainingTime;

  const PrayerInfoCard({
    super.key,
    required this.currentPrayer,
    required this.currentPrayerTime,
    required this.currentPrayerArabic,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.nextPrayerArabic,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1C6758),
            const Color(0xFF1C6758).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C6758).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPrayerSection(
            title: 'Şu anki vakit',
            prayerName: currentPrayer,
            prayerTime: currentPrayerTime,
            arabicName: currentPrayerArabic,
            icon: Icons.wb_sunny,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white24),
          ),
          _buildPrayerSection(
            title: 'Sonraki vakit',
            prayerName: nextPrayer,
            prayerTime: nextPrayerTime,
            arabicName: nextPrayerArabic,
            icon: Icons.nights_stay_outlined,
            showRemainingTime: true,
            remainingTime: remainingTime,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSection({
    required String title,
    required String prayerName,
    required String prayerTime,
    required String arabicName,
    required IconData icon,
    bool showRemainingTime = false,
    String remainingTime = '',
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                '$prayerName - $prayerTime',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                arabicName,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        if (showRemainingTime)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              remainingTime,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
} 