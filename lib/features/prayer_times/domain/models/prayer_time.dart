import 'package:flutter/material.dart';

class PrayerTime {
  final String name;
  final String arabicName;
  final String time;
  final IconData icon;
  final bool isActive;

  const PrayerTime({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.icon,
    this.isActive = false,
  });

  static List<PrayerTime> getMockPrayerTimes() {
    return [
      PrayerTime(
        name: "İmsak",
        arabicName: "الفجر",
        time: "04:21",
        icon: Icons.nights_stay,
        isActive: false,
      ),
      PrayerTime(
        name: "Güneş",
        arabicName: "الشروق",
        time: "05:48",
        icon: Icons.wb_twilight,
        isActive: false,
      ),
      PrayerTime(
        name: "Öğle",
        arabicName: "الظهر",
        time: "13:02",
        icon: Icons.wb_sunny,
        isActive: true,
      ),
      PrayerTime(
        name: "İkindi",
        arabicName: "العصر",
        time: "16:45",
        icon: Icons.sunny_snowing,
        isActive: false,
      ),
      PrayerTime(
        name: "Akşam",
        arabicName: "المغرب",
        time: "19:27",
        icon: Icons.nights_stay_outlined,
        isActive: false,
      ),
      PrayerTime(
        name: "Yatsı",
        arabicName: "العشاء",
        time: "20:54",
        icon: Icons.dark_mode,
        isActive: false,
      ),
    ];
  }
} 