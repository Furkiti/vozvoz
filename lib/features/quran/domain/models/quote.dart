class Quote {
  final String text;
  final String author;
  final int number;
  final bool isBookmarked;

  Quote({
    required this.text,
    required this.author,
    required this.number,
    this.isBookmarked = false,
  });

  Quote copyWith({
    String? text,
    String? author,
    int? number,
    bool? isBookmarked,
  }) {
    return Quote(
      text: text ?? this.text,
      author: author ?? this.author,
      number: number ?? this.number,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
} 