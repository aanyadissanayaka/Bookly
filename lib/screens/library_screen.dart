import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/book_storage.dart';
import '../data/mock_books.dart';
import '../models/book.dart';
import '../utils/app_colors.dart';
import '../widgets/book_card.dart';
import '../widgets/bookly_background.dart';

import 'add_book_screen.dart';
import 'book_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // Search box එකේ user type කරන text එක.
  String searchQuery = '';

  // User add කරන books.
  List<Book> userBooks = [];

  // User අන්තිමට open කරපු book එකේ ID එක.
  String? lastOpenedBookId;

  @override
  void initState() {
    super.initState();
    _loadLibraryData();
  }

  // --------------------------------------------------
  // LOAD LIBRARY DATA
  // --------------------------------------------------
  Future<void> _loadLibraryData() async {
    final savedBooks = await BookStorage.loadBooks();

    final prefs = await SharedPreferences.getInstance();

    final savedLastOpenedBookId = prefs.getString('last_opened_book_id');

    if (!mounted) return;

    setState(() {
      userBooks = savedBooks;
      lastOpenedBookId = savedLastOpenedBookId;
    });
  }

  // --------------------------------------------------
  // ADD NEW BOOK
  // --------------------------------------------------
  Future<void> _openAddBookScreen() async {
    final newBook = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );

    if (newBook == null) return;

    setState(() {
      userBooks.add(newBook);
    });

    await BookStorage.saveBooks(userBooks);
  }

  // --------------------------------------------------
  // OPEN BOOK DETAILS
  // --------------------------------------------------
  Future<void> _openBook(Book book) async {
    // User add කරපු book එකක්ද බලනවා.
    final canModify = userBooks.any((userBook) => userBook.id == book.id);

    // Last opened book update.
    setState(() {
      lastOpenedBookId = book.id;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('last_opened_book_id', book.id);

    if (!mounted) return;

    // Book details screen එක open කරනවා.
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => BookScreen(book: book, canModify: canModify),
      ),
    );

    // Latest last-opened ID reload කරනවා.
    final updatedPrefs = await SharedPreferences.getInstance();

    final updatedLastOpenedBookId = updatedPrefs.getString(
      'last_opened_book_id',
    );

    if (!mounted) return;

    setState(() {
      lastOpenedBookId = updatedLastOpenedBookId;
    });

    // Sample book එකක් නම් edit/delete නෑ.
    if (result == null || !canModify) {
      return;
    }

    final action = result['action'];
    final returnedBook = result['book'];

    if (returnedBook is! Book) return;

    // --------------------------------------------------
    // UPDATE BOOK
    // --------------------------------------------------
    if (action == 'update') {
      final index = userBooks.indexWhere(
        (savedBook) => savedBook.id == returnedBook.id,
      );

      if (index != -1) {
        setState(() {
          userBooks[index] = returnedBook;
        });

        await BookStorage.saveBooks(userBooks);
      }
    }
    // --------------------------------------------------
    // DELETE BOOK
    // --------------------------------------------------
    else if (action == 'delete') {
      setState(() {
        userBooks.removeWhere((savedBook) => savedBook.id == returnedBook.id);
      });

      await BookStorage.saveBooks(userBooks);

      // Delete කළ book එක last-opened එක නම්
      // saved ID එකත් remove කරනවා.
      if (lastOpenedBookId == returnedBook.id) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.remove('last_opened_book_id');

        if (!mounted) return;

        setState(() {
          lastOpenedBookId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default books + user books.
    final allBooks = [...mockBooks, ...userBooks];

    // --------------------------------------------------
    // CURRENTLY READING
    // --------------------------------------------------
    Book? currentBook;

    // Last opened book එක මුලින්ම use කරනවා.
    if (lastOpenedBookId != null) {
      for (final book in allBooks) {
        if (book.id == lastOpenedBookId) {
          currentBook = book;
          break;
        }
      }
    }

    // Last opened එකක් නැත්නම්
    // reading progress තියෙන book එක fallback.
    if (currentBook == null) {
      final currentlyReadingBooks = allBooks.where((book) {
        return book.progress > 0 && book.progress < 1;
      }).toList();

      if (currentlyReadingBooks.isNotEmpty) {
        currentBook = currentlyReadingBooks.last;
      }
    }

    // --------------------------------------------------
    // SEARCH FILTER
    // --------------------------------------------------
    final filteredBooks = allBooks.where((book) {
      final query = searchQuery.toLowerCase().trim();

      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      // Scaffold එක transparent කරන නිසා
      // common background එක පේනවා.
      backgroundColor: Colors.transparent,

      body: SafeArea(
        child: BooklyBackground(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // --------------------------------------------------
                    // TITLE + ADD BOOK
                    // --------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'My Library',

                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),

                        FilledButton.icon(
                          onPressed: _openAddBookScreen,

                          icon: const Icon(Icons.add_rounded),

                          label: const Text('Add Book'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --------------------------------------------------
                    // SEARCH
                    // --------------------------------------------------
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },

                      style: const TextStyle(color: AppColors.darkText),

                      decoration: InputDecoration(
                        hintText: 'Search your books...',

                        hintStyle: TextStyle(
                          color: AppColors.darkText.withValues(alpha: 0.55),
                        ),

                        prefixIcon: const Icon(Icons.search_rounded),

                        filled: true,

                        fillColor: AppColors.offWhite.withValues(alpha: 0.97),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),

                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --------------------------------------------------
                    // CURRENTLY READING TITLE
                    // --------------------------------------------------
                    const Text(
                      'Currently Reading',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --------------------------------------------------
                    // CURRENTLY READING CARD
                    // --------------------------------------------------
                    if (currentBook != null)
                      GestureDetector(
                        onTap: () async {
                          await _openBook(currentBook!);
                        },

                        child: _currentlyReadingCard(context, currentBook),
                      )
                    else
                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(18),

                        decoration: _cardDecoration(),

                        child: const Text(
                          'No book is currently being read.',

                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // --------------------------------------------------
                    // MY BOOKS
                    // --------------------------------------------------
                    const Text(
                      'My Books',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --------------------------------------------------
                    // RESPONSIVE GRID
                    // --------------------------------------------------
                    Expanded(
                      child: filteredBooks.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),

                                decoration: _cardDecoration(),

                                child: const Text(
                                  'No books found.',

                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                int columns;

                                if (constraints.maxWidth >= 900) {
                                  columns = 4;
                                } else if (constraints.maxWidth >= 650) {
                                  columns = 3;
                                } else {
                                  columns = 2;
                                }

                                return GridView.builder(
                                  itemCount: filteredBooks.length,

                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,

                                        crossAxisSpacing: 14,

                                        mainAxisSpacing: 14,

                                        childAspectRatio: 0.75,
                                      ),

                                  itemBuilder: (context, index) {
                                    final book = filteredBooks[index];

                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),

                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.06,
                                            ),

                                            blurRadius: 8,

                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),

                                      child: GestureDetector(
                                        onTap: () async {
                                          await _openBook(book);
                                        },

                                        child: BookCard(
                                          title: book.title,

                                          author: book.author,

                                          coverUrl: book.coverUrl,

                                          progress: book.progress,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CURRENTLY READING CARD
  // --------------------------------------------------
  Widget _currentlyReadingCard(BuildContext context, Book currentBook) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: _cardDecoration(),

      child: Row(
        children: [
          if (currentBook.coverUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: Image.network(
                currentBook.coverUrl,

                width: 65,
                height: 90,
                fit: BoxFit.cover,

                errorBuilder: (context, error, stackTrace) {
                  return _coverPlaceholder();
                },
              ),
            )
          else
            _coverPlaceholder(),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  currentBook.title,

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  currentBook.author,

                  style: TextStyle(
                    color: AppColors.darkText.withValues(alpha: 0.75),
                  ),
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: LinearProgressIndicator(
                    value: currentBook.progress,

                    minHeight: 6,

                    backgroundColor: AppColors.sage.withValues(alpha: 0.30),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '${(currentBook.progress * 100).toInt()}% completed',

                  style: const TextStyle(color: AppColors.darkText),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // BOOK COVER PLACEHOLDER
  // --------------------------------------------------
  Widget _coverPlaceholder() {
    return Container(
      width: 65,
      height: 90,

      decoration: BoxDecoration(
        color: AppColors.sage.withValues(alpha: 0.35),

        borderRadius: BorderRadius.circular(10),
      ),

      child: const Icon(
        Icons.menu_book_rounded,
        size: 42,
        color: AppColors.primary,
      ),
    );
  }

  // --------------------------------------------------
  // REUSABLE CARD DECORATION
  // --------------------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.offWhite.withValues(alpha: 0.97),

      borderRadius: BorderRadius.circular(18),

      border: Border.all(color: Colors.white.withValues(alpha: 0.65)),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),

          blurRadius: 12,

          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
