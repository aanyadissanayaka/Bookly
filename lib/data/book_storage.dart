import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';

class BookStorage {
  static const String _booksKey = 'bookly_saved_books';

  // --------------------------------------------------
  // SAVE BOOKS
  // --------------------------------------------------
  static Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedBooks = books
        .map((book) => jsonEncode(book.toJson()))
        .toList();

    await prefs.setStringList(_booksKey, encodedBooks);
  }

  // --------------------------------------------------
  // LOAD BOOKS
  // --------------------------------------------------
  static Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBooks = prefs.getStringList(_booksKey);

    if (savedBooks == null) {
      return [];
    }

    return savedBooks.map((bookString) {
      final decodedBook = jsonDecode(bookString);

      return Book.fromJson(Map<String, dynamic>.from(decodedBook));
    }).toList();
  }

  // --------------------------------------------------
  // CLEAR SAVED BOOKS
  // --------------------------------------------------
  // Testing හෝ reset feature එකකට පස්සේ use කරන්න පුළුවන්.
  static Future<void> clearBooks() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_booksKey);
  }
}
