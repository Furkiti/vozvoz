import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:vozvoz/core/services/location_service.dart';
import 'package:vozvoz/features/prayer_times/data/services/prayer_times_service.dart';
import 'package:vozvoz/features/prayer_times/presentation/providers/prayer_times_provider.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() {
  getIt.registerSingleton<LocationService>(LocationService());
  getIt.registerSingleton<PrayerTimesService>(PrayerTimesService());
  getIt.registerSingleton<PrayerTimesProvider>(
    PrayerTimesProvider(
      getIt<LocationService>(),
      getIt<PrayerTimesService>(),
    ),
  );
} 