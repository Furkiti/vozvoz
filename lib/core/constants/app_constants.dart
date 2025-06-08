class AppConstants {
  static const String appName = 'Vozvoz';
  
  // API Endpoints
  static const String baseUrl = 'https://api.aladhan.com/v1';
  static const String timingsByCity = '$baseUrl/timingsByCity';
  static const String timingsByAddress = '$baseUrl/timingsByAddress';
  static const String timingsByLatLong = '$baseUrl/timings';
  
  // Prayer Methods
  static const int turkeyMethod = 13; // Diyanet İşleri Başkanlığı
  
  // Shared Preferences Keys
  static const String lastKnownLatitude = 'last_known_latitude';
  static const String lastKnownLongitude = 'last_known_longitude';
  static const String lastKnownCity = 'last_known_city';
  static const String lastKnownCountry = 'last_known_country';
  static const String selectedLanguage = 'selected_language';
  static const String isDarkMode = 'is_dark_mode';
  static const String locationPermissionChecked = 'location_permission_checked';
  static const String cachedPrayerTimes = 'cached_prayer_times';
  static const String lastPrayerTimesFetch = 'last_prayer_times_fetch';
  
  // Cache Duration
  static const Duration prayerTimesCacheDuration = Duration(hours: 12);
  
  // Default Location (Ankara)
  static const double defaultLatitude = 39.9334;
  static const double defaultLongitude = 32.8597;
  static const String defaultCity = 'Ankara';
  static const String defaultCountry = 'Turkey';
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Layout Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultSpacing = 8.0;
} 