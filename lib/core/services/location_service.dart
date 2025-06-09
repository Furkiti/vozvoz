import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vozvoz/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return place.administrativeArea ?? place.locality ?? 'Bilinmeyen Konum';
      }
      return 'Bilinmeyen Konum';
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'Bilinmeyen Konum';
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