import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vozvoz/core/constants/app_constants.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_times.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

@injectable
class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  
  final Dio _dio = Dio();
  SharedPreferences? _prefs;
  final Connectivity _connectivity = Connectivity();
  Position? _lastPosition;
  
  PrayerTimesService._internal() {
    _dio.options.headers = {
      'Accept': 'application/json',
      'User-Agent': 'Vozvoz Prayer Times App',
    };
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  bool _hasLocationChanged(Position newPosition) {
    if (_lastPosition == null) return true;
    
    // 100 metre veya daha fazla hareket varsa konum değişmiş sayılır
    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );
    
    return distance >= 100;
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _cachePrayerTimes(PrayerTimes prayerTimes) async {
    await _initPrefs();
    await _prefs?.setString(AppConstants.cachedPrayerTimes, jsonEncode(prayerTimes.toJson()));
    await _prefs?.setString(AppConstants.lastPrayerTimesFetch, DateTime.now().toIso8601String());
  }

  Future<PrayerTimes?> _getCachedPrayerTimes() async {
    await _initPrefs();
    final cachedData = _prefs?.getString(AppConstants.cachedPrayerTimes);
    final lastFetch = _prefs?.getString(AppConstants.lastPrayerTimesFetch);

    if (cachedData != null && lastFetch != null) {
      final lastFetchTime = DateTime.parse(lastFetch);
      final now = DateTime.now();
      final difference = now.difference(lastFetchTime);

      if (difference < AppConstants.prayerTimesCacheDuration) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(cachedData);
          return PrayerTimes.fromJson(jsonData);
        } catch (e) {
          debugPrint('Error parsing cached prayer times: $e');
          return null;
        }
      }
    }
    return null;
  }

  Future<PrayerTimes?> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final newPosition = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      // Konum değişikliğini kontrol et
      final locationChanged = _hasLocationChanged(newPosition);
      _lastPosition = newPosition; // Son konumu güncelle

      // İnternet bağlantısını kontrol et
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        debugPrint('İnternet bağlantısı yok, önbellekten okuma deneniyor...');
        // İnternet yoksa önbellekten oku
        final cachedData = await _getCachedPrayerTimes();
        if (cachedData != null) {
          return cachedData;
        }
        throw Exception('İnternet bağlantısı yok ve önbellekte veri bulunamadı');
      }

      // Konum değişmediyse ve önbellekte veri varsa onu kullan
      if (!locationChanged) {
        final cachedData = await _getCachedPrayerTimes();
        if (cachedData != null) {
          return cachedData;
        }
      }

      // API'den yeni veri çek
      final response = await _dio.get(
        AppConstants.timingsByLatLong,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': AppConstants.turkeyMethod,
          'school': 1,
          'adjustment': 1,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        try {
          final prayerTimes = PrayerTimes.fromJson(response.data);
          // Yeni veriyi önbelleğe al
          await _cachePrayerTimes(prayerTimes);
          return prayerTimes;
        } catch (e) {
          debugPrint('API verisi ayrıştırma hatası: $e');
          // API verisi ayrıştırılamadıysa önbellekten okumayı dene
          final cachedData = await _getCachedPrayerTimes();
          if (cachedData != null) {
            return cachedData;
          }
          throw Exception('Namaz vakitleri verisi ayrıştırılamadı: $e');
        }
      } else {
        throw Exception('API yanıt vermedi veya hatalı yanıt döndü');
      }
    } catch (e) {
      debugPrint('Namaz vakitleri servisi hatası: $e');
      // Son bir kez önbellekten okumayı dene
      final cachedData = await _getCachedPrayerTimes();
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Namaz vakitleri alınamadı: $e');
    }
  }

  Future<PrayerTimes> getPrayerTimesFromHttp(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://api.aladhan.com/v1/timings/${DateTime.now().millisecondsSinceEpoch ~/ 1000}?latitude=$latitude&longitude=$longitude&method=13',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimes.fromJson(data['data']);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Failed to load prayer times: $e');
    }
  }
} 