import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'book_screen.dart';
import 'library_screen.dart';
import 'notes_quotes_screen.dart';
import 'profile_screen.dart';

import '../data/book_storage.dart';
import '../data/mock_books.dart';
import '../data/reading_tracker.dart';
import '../models/book.dart';
import '../utils/app_colors.dart';
import '../widgets/bookly_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _homeRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeContent(
        key: ValueKey(_homeRefreshKey),
        onViewAll: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
      const LibraryScreen(),
      const NotesQuotesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_selectedIndex]),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;

            // Home tab එක select කරන හැම වෙලාවකම
            // saved data නැවත load කරනවා.
            if (index == 0) {
              _homeRefreshKey++;
            }
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// HOME CONTENT
// --------------------------------------------------

class HomeContent extends StatefulWidget {
  final VoidCallback onViewAll;

  const HomeContent({super.key, required this.onViewAll});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // User add කරපු books.
  List<Book> userBooks = [];

  // Saved notes ගණන.
  int notesCount = 0;

  // Total reading time.
  int totalReadingMinutes = 0;

  // Reading streak.
  int readingStreak = 0;

  // Loading state.
  bool isLoading = true;

  // Search text.
  String searchQuery = '';

  // Saved reader name.
  String readerName = 'Bookly Reader';

  // Last opened book ID.
  String? lastOpenedBookId;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // --------------------------------------------------
  // LOAD HOME DATA
  // --------------------------------------------------
  Future<void> _loadHomeData() async {
    final savedBooks = await BookStorage.loadBooks();

    final prefs = await SharedPreferences.getInstance();

    final savedReadingMinutes = await ReadingTracker.getTotalMinutes();

    final savedStreak = await ReadingTracker.getStreak();

    final savedNotes = prefs.getStringList('bookly_notes') ?? [];

    final savedLastOpenedBookId = prefs.getString('last_opened_book_id');

    final savedReaderName = prefs.getString('reader_name');

    if (!mounted) return;

    setState(() {
      userBooks = savedBooks;

      notesCount = savedNotes.length;

      totalReadingMinutes = savedReadingMinutes;

      readingStreak = savedStreak;

      lastOpenedBookId = savedLastOpenedBookId;

      if (savedReaderName != null && savedReaderName.isNotEmpty) {
        readerName = savedReaderName;
      }

      isLoading = false;
    });
  }

  // --------------------------------------------------
  // OPEN BOOK
  // --------------------------------------------------
  Future<void> _openBook(Book book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookScreen(book: book)),
    );

    // Book screen එකෙන් ආපහු Home එකට ආවම
    // latest data නැවත load කරනවා.
    await _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------
    // ALL BOOKS
    // --------------------------------------------------
    final allBooks = [...mockBooks, ...userBooks];

    // --------------------------------------------------
    // SEARCH
    // --------------------------------------------------
    final filteredBooks = allBooks.where((book) {
      final query = searchQuery.toLowerCase().trim();

      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();

    // --------------------------------------------------
    // BOOKS READ
    // --------------------------------------------------
    final booksRead = allBooks.where((book) {
      return book.progress >= 1;
    }).length;

    // --------------------------------------------------
    // CURRENTLY READING
    // --------------------------------------------------
    Book? currentBook;

    // Last opened book එක මුලින් හොයනවා.
    if (lastOpenedBookId != null) {
      for (final book in allBooks) {
        if (book.id == lastOpenedBookId) {
          currentBook = book;
          break;
        }
      }
    }

    // Last opened book එකක් නැත්නම්
    // progress තියෙන book එක fallback.
    if (currentBook == null) {
      final currentlyReadingBooks = allBooks.where((book) {
        return book.progress > 0 && book.progress < 1;
      }).toList();

      if (currentlyReadingBooks.isNotEmpty) {
        currentBook = currentlyReadingBooks.last;
      }
    }

    // --------------------------------------------------
    // DYNAMIC GREETING
    // --------------------------------------------------
    final currentHour = DateTime.now().hour;

    String greeting;

    if (currentHour < 12) {
      greeting = 'Good Morning';
    } else if (currentHour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    // --------------------------------------------------
    // LOADING
    // --------------------------------------------------
    if (isLoading) {
      return const BooklyBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // --------------------------------------------------
    // HOME UI
    // --------------------------------------------------
    return BooklyBackground(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),

          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // --------------------------------------------------
                // LOGO + NOTIFICATION
                // --------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),

                      onTap: () {
                        setState(() {
                          searchQuery = '';
                        });
                      },

                      child: Image.asset(
                        'assets/images/bookly_logo.png',
                        width: 150,
                        fit: BoxFit.contain,
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.offWhite.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                      ),

                      child: IconButton(
                        onPressed: () {},

                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // --------------------------------------------------
                // GREETING + USER NAME
                // --------------------------------------------------
                Text(
                  '$greeting, $readerName',

                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Continue your reading journey.',

                  style: TextStyle(
                    fontSize: 16,

                    color: AppColors.darkText.withValues(alpha: 0.80),
                  ),
                ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // SEARCH BAR
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

                    fillColor: AppColors.offWhite.withValues(alpha: 0.96),

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

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),
                  ),
                ),

                // --------------------------------------------------
                // SEARCH RESULTS
                // --------------------------------------------------
                if (searchQuery.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,

                    constraints: const BoxConstraints(maxHeight: 260),

                    decoration: BoxDecoration(
                      color: AppColors.offWhite.withValues(alpha: 0.98),

                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: filteredBooks.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                              'No books found.',
                              style: TextStyle(color: AppColors.darkText),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,

                            itemCount: filteredBooks.length,

                            separatorBuilder: (context, index) {
                              return const Divider(height: 1);
                            },

                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];

                              return ListTile(
                                leading: const Icon(Icons.menu_book_rounded),

                                title: Text(book.title),

                                subtitle: Text(book.author),

                                onTap: () async {
                                  await _openBook(book);
                                },
                              );
                            },
                          ),
                  ),
                ],

                const SizedBox(height: 36),

                // --------------------------------------------------
                // CURRENTLY READING TITLE
                // --------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'Currently Reading',

                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    TextButton(
                      onPressed: widget.onViewAll,

                      child: const Text('View All'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // --------------------------------------------------
                // CURRENTLY READING CARD
                // --------------------------------------------------
                if (currentBook != null)
                  GestureDetector(
                    onTap: () async {
                      await _openBook(currentBook!);
                    },

                    child: _glassCard(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),

                            child: currentBook.coverUrl.isEmpty
                                ? _coverPlaceholder(context)
                                : Image.network(
                                    currentBook.coverUrl,

                                    width: 85,
                                    height: 120,
                                    fit: BoxFit.cover,

                                    errorBuilder: (context, error, stackTrace) {
                                      return _coverPlaceholder(context);
                                    },
                                  ),
                          ),

                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  currentBook.title,

                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  currentBook.author,

                                  style: TextStyle(
                                    color: AppColors.darkText.withValues(
                                      alpha: 0.75,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),

                                  child: LinearProgressIndicator(
                                    value: currentBook.progress,

                                    minHeight: 7,

                                    backgroundColor: AppColors.sage.withValues(
                                      alpha: 0.30,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  '${(currentBook.progress * 100).toInt()}% completed',

                                  style: const TextStyle(
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _glassCard(
                    child: const Text(
                      'No book is currently being read.',

                      style: TextStyle(color: AppColors.darkText),
                    ),
                  ),

                const SizedBox(height: 18),

                // --------------------------------------------------
                // TODAY'S GOAL + STREAK
                // --------------------------------------------------
                _glassCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,

                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,

                        child: Icon(
                          Icons.local_fire_department_rounded,

                          color: Theme.of(context).colorScheme.primary,

                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Today's Goal",

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'Read for 20 minutes',

                              style: TextStyle(color: AppColors.darkText),
                            ),
                          ],
                        ),
                      ),

                      Container(width: 1, height: 50, color: AppColors.sage),

                      const SizedBox(width: 16),

                      Column(
                        children: [
                          Text(
                            readingStreak.toString(),

                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),

                          const Text(
                            'day streak',

                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // --------------------------------------------------
                // READING STATISTICS
                // --------------------------------------------------
                const Text(
                  'Reading Statistics',

                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.auto_stories_rounded,

                        value: booksRead.toString(),

                        label: 'Books Read',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _statCard(
                        icon: Icons.schedule_rounded,

                        value: ReadingTracker.formatReadingTime(
                          totalReadingMinutes,
                        ),

                        label: 'Reading Time',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _statCard(
                        icon: Icons.edit_note_rounded,

                        value: notesCount.toString(),

                        label: 'Notes',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // --------------------------------------------------
                // RECENTLY ADDED
                // --------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'Recently Added',

                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    TextButton(
                      onPressed: widget.onViewAll,

                      child: const Text('View All'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 190,

                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,

                    itemCount: allBooks.length,

                    separatorBuilder: (context, index) {
                      return const SizedBox(width: 14);
                    },

                    itemBuilder: (context, index) {
                      final reversedBooks = allBooks.reversed.toList();

                      final book = reversedBooks[index];

                      return GestureDetector(
                        onTap: () async {
                          await _openBook(book);
                        },

                        child: SizedBox(
                          width: 105,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),

                                child: book.coverUrl.isEmpty
                                    ? _smallCoverPlaceholder(context)
                                    : Image.network(
                                        book.coverUrl,

                                        width: 105,
                                        height: 140,

                                        fit: BoxFit.cover,

                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return _smallCoverPlaceholder(
                                                context,
                                              );
                                            },
                                      ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                book.title,

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                book.author,

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  fontSize: 12,

                                  color: AppColors.darkText.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // GLASS CARD
  // --------------------------------------------------
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        // Background image එක පේනවා,
        // text එකත් clear.
        color: AppColors.offWhite.withValues(alpha: 0.96),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white.withValues(alpha: 0.60)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),

            blurRadius: 12,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  // --------------------------------------------------
  // STAT CARD
  // --------------------------------------------------
  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),

      decoration: BoxDecoration(
        color: AppColors.offWhite.withValues(alpha: 0.96),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.white.withValues(alpha: 0.60)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),

            blurRadius: 8,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),

          const SizedBox(height: 8),

          Text(
            value,

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,

            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 12, color: AppColors.darkText),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // LARGE COVER PLACEHOLDER
  // --------------------------------------------------
  Widget _coverPlaceholder(BuildContext context) {
    return Container(
      width: 85,
      height: 120,

      color: Theme.of(context).colorScheme.primaryContainer,

      child: const Icon(Icons.menu_book_rounded, size: 42),
    );
  }

  // --------------------------------------------------
  // SMALL COVER PLACEHOLDER
  // --------------------------------------------------
  Widget _smallCoverPlaceholder(BuildContext context) {
    return Container(
      width: 105,
      height: 140,

      color: Theme.of(context).colorScheme.primaryContainer,

      child: const Icon(Icons.menu_book_rounded, size: 35),
    );
  }
}
