import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vozvoz/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> checkPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Konum servisi açık mı: $serviceEnabled');
      
      if (!serviceEnabled) {
        debugPrint('Konum servisi kapalı, açılması isteniyor');
        // Konum servisini açmak için kullanıcıyı ayarlara yönlendir
        await Geolocator.openLocationSettings();
        // Kullanıcının ayarları açıp servisi etkinleştirmesi için biraz bekle
        await Future.delayed(const Duration(seconds: 3));
        // Tekrar kontrol et
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint('Konum servisi hala kapalı');
          return false;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('İlk izin kontrolü: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('İzin istendi, yeni durum: $permission');
        if (permission == LocationPermission.denied) {
          debugPrint('İzin reddedildi');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('İzin kalıcı olarak reddedildi');
        // Kullanıcıyı uygulama ayarlarına yönlendir
        await Geolocator.openAppSettings();
        return false;
      }

      debugPrint('İzin alındı');
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('İzin kontrolünde hata: $e');
      return false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      debugPrint('Konum alınmaya çalışılıyor...');
      
      // Önce son bilinen konumu al
      Position? lastKnownPosition = await getLastKnownLocation();
      
      // İzinleri kontrol et
      if (!await checkPermission()) {
        debugPrint('İzin olmadığı için son bilinen konum kullanılıyor');
        return lastKnownPosition;
      }

      try {
        // Yeni konumu almayı dene
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        debugPrint('Yeni konum alındı: ${position.latitude}, ${position.longitude}');
        return position;
      } catch (timeoutError) {
        debugPrint('Konum alma zaman aşımına uğradı, son konum kullanılıyor');
        if (lastKnownPosition != null) {
          return lastKnownPosition;
        }
        
        // Son çare: Varsayılan konum
        return Position(
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
      }
    } catch (e) {
      debugPrint('Konum alınırken hata: $e');
      return getLastKnownLocation();
    }
  }

  Future<String> getAddressFromPosition(Position position) async {
    try {
      // Önce SharedPreferences'dan kayıtlı şehir adını kontrol et
      final prefs = await SharedPreferences.getInstance();
      final lastKnownCity = prefs.getString(AppConstants.lastKnownCity);
      
      if (lastKnownCity != null) {
        debugPrint('Kayıtlı şehir adı kullanılıyor: $lastKnownCity');
        return lastKnownCity;
      }

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.administrativeArea ?? place.locality ?? '';
        if (city.isNotEmpty) {
          // Şehir adını kaydet
          await prefs.setString(AppConstants.lastKnownCity, city);
          debugPrint('Şehir bulundu ve kaydedildi: $city');
          return city;
        }
      }
      return AppConstants.defaultCity;
    } catch (e) {
      debugPrint('Adres çözümlenirken hata: $e');
      return AppConstants.defaultCity;
    }
  }

  Future<void> saveLastKnownLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(AppConstants.lastKnownLatitude, position.latitude);
      await prefs.setDouble(AppConstants.lastKnownLongitude, position.longitude);
      debugPrint('Son konum kaydedildi: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Konum kaydedilirken hata: $e');
    }
  }

  Future<Position?> getLastKnownLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble(AppConstants.lastKnownLatitude);
      final longitude = prefs.getDouble(AppConstants.lastKnownLongitude);

      if (latitude == null || longitude == null) {
        debugPrint('Kayıtlı konum bulunamadı, varsayılan konum kullanılıyor');
        return Position(
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
      }

      debugPrint('Kayıtlı konum alındı: $latitude, $longitude');
      return Position(
        longitude: longitude,
        latitude: latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } catch (e) {
      debugPrint('Son konum alınırken hata: $e');
      return null;
    }
  }
} 