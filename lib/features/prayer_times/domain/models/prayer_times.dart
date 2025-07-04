import 'package:intl/intl.dart';

class PrayerTimes {
  final DateTime date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  
  String get hijriDate => getFormattedDate();
  String get gregorianDate => DateFormat('d MMMM yyyy', 'tr_TR').format(date);

  PrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      if (data == null) throw Exception('Data is null');

      final timings = data['timings'];
      if (timings == null) throw Exception('Timings is null');

      final dateStr = data['date']['gregorian']['date'];
      if (dateStr == null) throw Exception('Date is null');

      // Parse date
      final date = DateFormat('dd-MM-yyyy').parse(dateStr);

      return PrayerTimes(
        date: date,
        fajr: _cleanTime(timings['Fajr'] ?? ''),
        sunrise: _cleanTime(timings['Sunrise'] ?? ''),
        dhuhr: _cleanTime(timings['Dhuhr'] ?? ''),
        asr: _cleanTime(timings['Asr'] ?? ''),
        maghrib: _cleanTime(timings['Maghrib'] ?? ''),
        isha: _cleanTime(timings['Isha'] ?? ''),
      );
    } catch (e) {
      throw Exception('Error parsing prayer times: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
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
            'date': DateFormat('dd-MM-yyyy').format(date),
          },
        },
      },
    };
  }

  static String _cleanTime(String time) {
    // (24 Hour) formatından parantezleri temizle
    return time.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  }

  String getFormattedDate() {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
  }

  String getCurrentPrayer() {
    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);
    
    final times = [
      {'name': 'İmsak', 'start': fajr, 'end': sunrise},
      {'name': 'Güneş', 'start': sunrise, 'end': dhuhr},
      {'name': 'Öğle', 'start': dhuhr, 'end': asr},
      {'name': 'İkindi', 'start': asr, 'end': maghrib},
      {'name': 'Akşam', 'start': maghrib, 'end': isha},
      {'name': 'Yatsı', 'start': isha, 'end': '23:59'},
    ];

    // Gece yarısından imsak vaktine kadar olan özel durum
    if (currentTime.compareTo('00:00') >= 0 && currentTime.compareTo(fajr) < 0) {
      return 'Yatsı';
    }

    for (var prayer in times) {
      if (_isTimeBetween(currentTime, prayer['start']!, prayer['end']!)) {
        return prayer['name']!;
      }
    }

    return 'Yatsı'; // Varsayılan olarak
  }

  String getCurrentPrayerTime() {
    final currentPrayer = getCurrentPrayer();
    String time;
    
    switch (currentPrayer) {
      case 'İmsak':
        time = fajr;
        break;
      case 'Güneş':
        time = sunrise;
        break;
      case 'Öğle':
        time = dhuhr;
        break;
      case 'İkindi':
        time = asr;
        break;
      case 'Akşam':
        time = maghrib;
        break;
      case 'Yatsı':
        time = isha;
        break;
      default:
        time = fajr;
    }
    
    return time;
  }

  String getCurrentPrayerArabic() {
    final currentPrayer = getCurrentPrayer();
    switch (currentPrayer) {
      case 'İmsak':
        return 'الفجر';
      case 'Güneş':
        return 'الشروق';
      case 'Öğle':
        return 'الظهر';
      case 'İkindi':
        return 'العصر';
      case 'Akşam':
        return 'المغرب';
      case 'Yatsı':
        return 'العشاء';
      default:
        return 'الفجر';
    }
  }

  String getNextPrayer() {
    final currentPrayer = getCurrentPrayer();
    final times = [
      'İmsak',
      'Güneş',
      'Öğle',
      'İkindi',
      'Akşam',
      'Yatsı',
    ];

    final currentIndex = times.indexOf(currentPrayer);
    if (currentIndex == -1 || currentIndex == times.length - 1) {
      return 'İmsak';
    }

    return times[currentIndex + 1];
  }

  String getNextPrayerTime() {
    final nextPrayer = getNextPrayer();
    String time;
    
    switch (nextPrayer) {
      case 'İmsak':
        time = fajr;
        break;
      case 'Güneş':
        time = sunrise;
        break;
      case 'Öğle':
        time = dhuhr;
        break;
      case 'İkindi':
        time = asr;
        break;
      case 'Akşam':
        time = maghrib;
        break;
      case 'Yatsı':
        time = isha;
        break;
      default:
        time = fajr;
    }
    
    return time;
  }

  String getNextPrayerArabic() {
    final nextPrayer = getNextPrayer();
    switch (nextPrayer) {
      case 'İmsak':
        return 'الفجر';
      case 'Güneş':
        return 'الشروق';
      case 'Öğle':
        return 'الظهر';
      case 'İkindi':
        return 'العصر';
      case 'Akşam':
        return 'المغرب';
      case 'Yatsı':
        return 'العشاء';
      default:
        return 'الفجر';
    }
  }

  String getRemainingTime() {
    final now = DateTime.now();
    final currentTimeStr = DateFormat('HH:mm').format(now);
    
    final times = [
      {'name': 'İmsak', 'time': fajr},
      {'name': 'Güneş', 'time': sunrise},
      {'name': 'Öğle', 'time': dhuhr},
      {'name': 'İkindi', 'time': asr},
      {'name': 'Akşam', 'time': maghrib},
      {'name': 'Yatsı', 'time': isha},
    ];

    for (var prayer in times) {
      final prayerTime = DateFormat('HH:mm').parse(prayer['time']!);
      final currentTime = DateFormat('HH:mm').parse(currentTimeStr);
      
      if (currentTime.isBefore(prayerTime)) {
        final difference = prayerTime.difference(currentTime);
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        return '$hours saat $minutes dakika';
      }
    }

    // Eğer tüm vakitler geçmişse, yarının ilk vaktine kalan süre
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final nextFajr = DateFormat('HH:mm').parse(fajr);
    final difference = tomorrow.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    return '$hours saat $minutes dakika';
  }

  bool _isTimeBetween(String time, String start, String end) {
    // Eğer bitiş zamanı başlangıç zamanından küçükse (gece yarısını geçen durumlar için)
    if (end.compareTo(start) < 0) {
      return time.compareTo(start) >= 0 || time.compareTo(end) < 0;
    }
    return time.compareTo(start) >= 0 && time.compareTo(end) < 0;
  }
} 