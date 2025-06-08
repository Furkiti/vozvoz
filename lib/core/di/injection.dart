import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:vozvoz/core/constants/app_constants.dart';
import 'package:vozvoz/features/prayer_times/data/repositories/prayer_times_repository_impl.dart';
import 'package:vozvoz/features/prayer_times/domain/repositories/prayer_times_repository.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // Register Dio
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));

    return dio;
  });

  // Register Repositories
  getIt.registerLazySingleton<PrayerTimesRepository>(
    () => PrayerTimesRepositoryImpl(getIt<Dio>()),
  );
} 