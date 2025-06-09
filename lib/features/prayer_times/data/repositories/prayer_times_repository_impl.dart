import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:vozvoz/core/constants/app_constants.dart';
import 'package:vozvoz/features/prayer_times/domain/models/prayer_times.dart';
import 'package:vozvoz/features/prayer_times/domain/repositories/prayer_times_repository.dart';

@Injectable()
class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  final Dio _dio;

  PrayerTimesRepositoryImpl(this._dio);

  @override
  Future<PrayerTimes> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.timingsByLatLong,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': AppConstants.turkeyMethod,
          'date': date?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return PrayerTimes.fromJson(response.data);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Failed to load prayer times: $e');
    }
  }

  @override
  Future<PrayerTimes> getPrayerTimesByCity({
    required String city,
    required String country,
    DateTime? date,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.timingsByCity,
        queryParameters: {
          'city': city,
          'country': country,
          'method': AppConstants.turkeyMethod,
          'date': date?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return PrayerTimes.fromJson(response.data);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Failed to load prayer times: $e');
    }
  }

  @override
  Future<PrayerTimes> getPrayerTimesByAddress({
    required String address,
    DateTime? date,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.timingsByAddress,
        queryParameters: {
          'address': address,
          'method': AppConstants.turkeyMethod,
          'date': date?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return PrayerTimes.fromJson(response.data);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Failed to load prayer times: $e');
    }
  }
} 