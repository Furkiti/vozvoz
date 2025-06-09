import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vozvoz/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Placemark> getPlacemarkFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first;
      } else {
        throw Exception('No placemark found for the given coordinates');
      }
    } catch (e) {
      throw Exception('Error getting address: $e');
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