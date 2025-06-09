import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:vozvoz/core/services/location_service.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_time.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_times.dart';
import 'package:vozvoz/features/prayer_times/domain/repositories/prayer_times_repository.dart';
import 'package:vozvoz/core/constants/app_constants.dart';

@injectable
class PrayerTimesProvider extends ChangeNotifier {
  final LocationService _locationService;
  final PrayerTimesRepository _prayerTimesRepository;
  Timer? _timer;

  PrayerTimes? _prayerTimes;
  List<PrayerTime> _prayerTimesList = [];
  String _locationText = 'Konum alınıyor...';
  bool _isLoading = true;
  bool _hasError = false;
  String _remainingTime = '';

  // Getters
  PrayerTimes? get prayerTimes => _prayerTimes;
  List<PrayerTime> get prayerTimesList => _prayerTimesList;
  String get locationText => _locationText;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get remainingTime => _remainingTime;

  PrayerTimesProvider(this._locationService, this._prayerTimesRepository) {
    initializePrayerTimes();
    // Her dakika kalan süreyi güncelle
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initializePrayerTimes() async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        await _useDefaultLocation();
        return;
      }

      await _updatePrayerTimes(position);
    } catch (e) {
      debugPrint('Prayer times initialization error: $e');
      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _useDefaultLocation() async {
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

    _locationText = AppConstants.defaultCity;
    await _updatePrayerTimes(defaultPosition);
  }

  Future<void> _updatePrayerTimes(Position position) async {
    try {
      final cityName = await _locationService.getAddressFromPosition(position);
      _locationText = cityName;

      final prayerTimes = await _prayerTimesRepository.getPrayerTimesByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _prayerTimes = prayerTimes;
      _updatePrayerTimesList();
      _updateRemainingTime();
      _hasError = false;
    } catch (e) {
      debugPrint('Update prayer times error: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      _remainingTime = _prayerTimes!.getRemainingTime();
      notifyListeners();
    }
  }
} 