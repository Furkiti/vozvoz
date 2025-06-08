class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final DateTime date;
  final String timezone;
  
  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.timezone,
  });
  
  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date']['gregorian']['date'] as String;
    
    return PrayerTimes(
      fajr: timings['Fajr'] as String,
      sunrise: timings['Sunrise'] as String,
      dhuhr: timings['Dhuhr'] as String,
      asr: timings['Asr'] as String,
      maghrib: timings['Maghrib'] as String,
      isha: timings['Isha'] as String,
      date: DateTime.parse(date),
      timezone: json['meta']['timezone'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'timings': {
        'Fajr': fajr,
        'Sunrise': sunrise,
        'Dhuhr': dhuhr,
        'Asr': asr,
        'Maghrib': maghrib,
        'Isha': isha,
      },
      'date': {
        'gregorian': {
          'date': date.toIso8601String(),
        },
      },
      'meta': {
        'timezone': timezone,
      },
    };
  }
} 