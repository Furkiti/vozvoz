import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:vozvoz/core/services/location_service.dart';
import 'package:vozvoz/features/prayer_times/data/services/prayer_times_service.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_time.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_times.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

@injectable
class PrayerTimesProvider extends ChangeNotifier {
  final LocationService _locationService;
  final PrayerTimesService _prayerTimesService;

  PrayerTimes? _prayerTimes;
  List<PrayerTime> _prayerTimesList = [];
  String _locationText = '';
  String _remainingTime = '';
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _timer;
  Timer? _updateTimer;

  PrayerTimesProvider(
    this._locationService,
    this._prayerTimesService,
  ) {
    _initializePrayerTimes();
    _startTimers();
  }

  void _startTimers() {
    // Cancel existing timers if any
    _timer?.cancel();
    _updateTimer?.cancel();

    // Start a timer that ticks exactly at the start of each second
    final now = DateTime.now();
    final nextSecond = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second + 1,
    );
    final delay = nextSecond.difference(now);

    // Initial delay to sync with system clock
    Future.delayed(delay, () {
      // Update immediately
      _updateTimes();

      // Then setup periodic timer
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateTimes();
      });
    });
  }

  void _updateTimes() {
    _updateRemainingTime();
    notifyListeners();
  }

  // Getters
  PrayerTimes? get prayerTimes => _prayerTimes;
  List<PrayerTime> get prayerTimesList => _prayerTimesList;
  String get locationText => _locationText;
  String get remainingTime => _remainingTime;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  String get localTime {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  String get hijriDate {
    var _hijri = HijriCalendar.now();
    return '${_hijri.hDay} ${_getHijriMonthName(_hijri.hMonth)} ${_hijri.hYear}';
  }

  String _getHijriMonthName(int month) {
    const months = [
      'Muharrem',
      'Safer',
      'Rebiülevvel',
      'Rebiülahir',
      'Cemaziyelevvel',
      'Cemaziyelahir',
      'Recep',
      'Şaban',
      'Ramazan',
      'Şevval',
      'Zilkade',
      'Zilhicce'
    ];
    return months[month - 1];
  }

  Future<void> _initializePrayerTimes() async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final position = await _locationService.getCurrentPosition();
      final placemark = await _locationService.getPlacemarkFromPosition(position);
      
      _locationText = '${placemark.subAdministrativeArea}, ${placemark.administrativeArea}';
      
      _prayerTimes = await _prayerTimesService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _updatePrayerTimesList();
      _updateRemainingTime();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      notifyListeners();
    }
  }

  Future<void> refreshPrayerTimes() async {
    await _initializePrayerTimes();
  }

  void _updatePrayerTimesList() {
    if (_prayerTimes == null) return;

    _prayerTimesList = [
      PrayerTime(
        name: "İmsak",
        arabicName: "الفجر",
        time: _prayerTimes!.fajr,
        icon: Icons.nights_stay,
        isActive: _prayerTimes!.getCurrentPrayer() == "İmsak",
      ),
      PrayerTime(
        name: "Güneş",
        arabicName: "الشروق",
        time: _prayerTimes!.sunrise,
        icon: Icons.wb_twilight,
        isActive: false,
      ),
      PrayerTime(
        name: "Öğle",
        arabicName: "الظهر",
        time: _prayerTimes!.dhuhr,
        icon: Icons.wb_sunny,
        isActive: _prayerTimes!.getCurrentPrayer() == "Öğle",
      ),
      PrayerTime(
        name: "İkindi",
        arabicName: "العصر",
        time: _prayerTimes!.asr,
        icon: Icons.sunny_snowing,
        isActive: _prayerTimes!.getCurrentPrayer() == "İkindi",
      ),
      PrayerTime(
        name: "Akşam",
        arabicName: "المغرب",
        time: _prayerTimes!.maghrib,
        icon: Icons.nights_stay_outlined,
        isActive: _prayerTimes!.getCurrentPrayer() == "Akşam",
      ),
      PrayerTime(
        name: "Yatsı",
        arabicName: "العشاء",
        time: _prayerTimes!.isha,
        icon: Icons.dark_mode,
        isActive: _prayerTimes!.getCurrentPrayer() == "Yatsı",
      ),
    ];
  }

  void _updateRemainingTime() {
    if (_prayerTimes != null) {
      final now = DateTime.now();
      final currentPrayer = _prayerTimesList.firstWhere(
        (prayer) => prayer.isActive,
        orElse: () => _prayerTimesList.first,
      );
      final currentIndex = _prayerTimesList.indexOf(currentPrayer);
      final nextPrayer = currentIndex < _prayerTimesList.length - 1
          ? _prayerTimesList[currentIndex + 1]
          : _prayerTimesList.first;

      // Parse next prayer time
      final timeFormat = DateFormat('HH:mm');
      final nextPrayerTime = timeFormat.parse(nextPrayer.time);
      final nextPrayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        nextPrayerTime.hour,
        nextPrayerTime.minute,
      );

      // If next prayer time is earlier than current time, it's for tomorrow
      final targetDateTime = nextPrayerDateTime.isBefore(now)
          ? nextPrayerDateTime.add(const Duration(days: 1))
          : nextPrayerDateTime;

      final difference = targetDateTime.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      if (hours > 0) {
        _remainingTime = '$hours saat $minutes dakika $seconds saniye';
      } else if (minutes > 0) {
        _remainingTime = '$minutes dakika $seconds saniye';
      } else {
        _remainingTime = '$seconds saniye';
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }
} 