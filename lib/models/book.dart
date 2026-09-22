class Book {
  // එක් එක් පොත හඳුනාගන්න unique ID එක.
  final String id;

  // පොතේ නම.
  final String title;

  // කතුවරයාගේ නම.
  final String author;

  // Book cover image URL එක.
  final String coverUrl;

  // Reading progress:
  // 0.0 = 0%
  // 0.5 = 50%
  // 1.0 = 100%
  final double progress;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.progress = 0.0,
  });

  // --------------------------------------------------
  // BOOK -> JSON
  // --------------------------------------------------
  // Book object එක local storage එකේ save කරන්න පුළුවන්
  // Map format එකකට convert කරනවා.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'progress': progress,
    };
  }

  // --------------------------------------------------
  // JSON -> BOOK
  // --------------------------------------------------
  // Local storage එකෙන් load කරන data
  // නැවත Book object එකක් බවට convert කරනවා.
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['coverUrl'] as String,
      progress: (json['progress'] as num).toDouble(),
    );
  }

  // --------------------------------------------------
  // COPY BOOK WITH CHANGES
  // --------------------------------------------------
  // පස්සේ Edit Book / Update Progress කරනකොට
  // existing book එකේ values කිහිපයක් විතරක් වෙනස් කරන්න
  // මේ method එක භාවිතා කරන්න පුළුවන්.
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    double? progress,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      progress: progress ?? this.progress,
    );
  }
}
