class Hadith {
  final String text;
  final String source;
  final int number;
  final bool isBookmarked;

  Hadith({
    required this.text,
    required this.source,
    required this.number,
    this.isBookmarked = false,
  });

  Hadith copyWith({
    String? text,
    String? source,
    int? number,
    bool? isBookmarked,
  }) {
    return Hadith(
      text: text ?? this.text,
      source: source ?? this.source,
      number: number ?? this.number,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
} 