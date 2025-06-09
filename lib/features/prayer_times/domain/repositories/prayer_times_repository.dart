import '../models/prayer_times.dart';

abstract class PrayerTimesRepository {
  Future<PrayerTimes> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    DateTime? date,
  });

  Future<PrayerTimes> getPrayerTimesByCity({
    required String city,
    required String country,
    DateTime? date,
  });

  Future<PrayerTimes> getPrayerTimesByAddress({
    required String address,
    DateTime? date,
  });
} 