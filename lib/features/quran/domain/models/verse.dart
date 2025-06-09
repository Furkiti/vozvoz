class Verse {
  final String arabicText;
  final String turkishText;
  final String surahName;
  final int verseNumber;
  final bool isBookmarked;

  Verse({
    required this.arabicText,
    required this.turkishText,
    required this.surahName,
    required this.verseNumber,
    this.isBookmarked = false,
  });

  Verse copyWith({
    String? arabicText,
    String? turkishText,
    String? surahName,
    int? verseNumber,
    bool? isBookmarked,
  }) {
    return Verse(
      arabicText: arabicText ?? this.arabicText,
      turkishText: turkishText ?? this.turkishText,
      surahName: surahName ?? this.surahName,
      verseNumber: verseNumber ?? this.verseNumber,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
} 