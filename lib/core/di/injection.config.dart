// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:vozvoz/core/di/injection.dart' as _i276;
import 'package:vozvoz/core/services/location_service.dart' as _i317;
import 'package:vozvoz/features/prayer_times/data/repositories/prayer_times_repository_impl.dart'
    as _i545;
import 'package:vozvoz/features/prayer_times/domain/repositories/prayer_times_repository.dart'
    as _i895;
import 'package:vozvoz/features/prayer_times/presentation/providers/prayer_times_provider.dart'
    as _i52;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.factory<_i317.LocationService>(() => _i317.LocationService());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i895.PrayerTimesRepository>(
        () => registerModule.prayerTimesRepository);
    gh.factory<_i545.PrayerTimesRepositoryImpl>(
        () => _i545.PrayerTimesRepositoryImpl(gh<_i361.Dio>()));
    gh.factory<_i52.PrayerTimesProvider>(() => _i52.PrayerTimesProvider(
          gh<_i317.LocationService>(),
          gh<_i895.PrayerTimesRepository>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i276.RegisterModule {}
