import 'package:flutter/material.dart';
import 'package:vozvoz/features/quran/domain/models/verse.dart';
import 'package:vozvoz/features/quran/domain/models/hadith.dart';
import 'package:vozvoz/features/quran/domain/models/quote.dart';

class QuranProvider extends ChangeNotifier {
  List<Verse> _verses = [];
  List<Hadith> _hadiths = [];
  List<Quote> _quotes = [];

  List<Verse> get verses => _verses;
  List<Hadith> get hadiths => _hadiths;
  List<Quote> get quotes => _quotes;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  QuranProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // TODO: Load data from a real API or local storage
    await Future.delayed(const Duration(seconds: 1)); // Simulating API call

    _verses = List.generate(
      40,
      (index) => Verse(
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        turkishText: 'Rahman ve Rahim olan Allah\'ın adıyla',
        surahName: 'Bakara Suresi',
        verseNumber: index + 1,
      ),
    );

    _hadiths = List.generate(
      40,
      (index) => Hadith(
        text: 'Kolaylaştırınız, zorlaştırmayınız. Müjdeleyiniz, nefret ettirmeyiniz.',
        source: 'Buhârî, İlim, 11',
        number: index + 1,
      ),
    );

    _quotes = List.generate(
      40,
      (index) => Quote(
        text: 'Cahillik, kendini bilmemektir. Kendini bilen, Rabbini bilir.',
        author: 'Hz. Ali (r.a)',
        number: index + 1,
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  void toggleVerseBookmark(int index) {
    _verses[index] = _verses[index].copyWith(
      isBookmarked: !_verses[index].isBookmarked,
    );
    notifyListeners();
  }

  void toggleHadithBookmark(int index) {
    _hadiths[index] = _hadiths[index].copyWith(
      isBookmarked: !_hadiths[index].isBookmarked,
    );
    notifyListeners();
  }

  void toggleQuoteBookmark(int index) {
    _quotes[index] = _quotes[index].copyWith(
      isBookmarked: !_quotes[index].isBookmarked,
    );
    notifyListeners();
  }

  Verse? getDailyVerse() {
    if (_verses.isEmpty) return null;
    // TODO: Implement logic to select a different verse each day
    return _verses[0];
  }

  Hadith? getDailyHadith() {
    if (_hadiths.isEmpty) return null;
    // TODO: Implement logic to select a different hadith each day
    return _hadiths[0];
  }

  Quote? getDailyQuote() {
    if (_quotes.isEmpty) return null;
    // TODO: Implement logic to select a different quote each day
    return _quotes[0];
  }
} 