import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/reading_tracker.dart';
import '../models/book.dart';
import '../utils/app_colors.dart';
import '../widgets/bookly_background.dart';

class BookScreen extends StatefulWidget {
  final Book book;

  // User add කරපු book එකක්ද කියලා හඳුනාගන්න.
  // Sample books වල Edit/Delete allow කරන්නේ නැහැ.
  final bool canModify;

  const BookScreen({super.key, required this.book, this.canModify = false});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  late Book currentBook;

  // Reading session එක run වෙනවද?
  bool isReading = false;

  // Current session seconds.
  int elapsedSeconds = 0;

  Timer? readingTimer;

  @override
  void initState() {
    super.initState();

    currentBook = widget.book;

    // මේ book එක last opened book විදිහට save කරනවා.
    _saveLastOpenedBook();
  }

  // --------------------------------------------------
  // SAVE LAST OPENED BOOK
  // --------------------------------------------------
  Future<void> _saveLastOpenedBook() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('last_opened_book_id', currentBook.id);
  }

  @override
  void dispose() {
    readingTimer?.cancel();

    super.dispose();
  }

  // --------------------------------------------------
  // START READING SESSION
  // --------------------------------------------------
  void _startReadingSession() {
    if (isReading) return;

    setState(() {
      isReading = true;
      elapsedSeconds = 0;
    });

    readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        elapsedSeconds++;
      });
    });
  }

  // --------------------------------------------------
  // FINISH READING SESSION
  // --------------------------------------------------
  Future<void> _finishReadingSession() async {
    readingTimer?.cancel();

    final minutes = (elapsedSeconds / 60).ceil();

    if (minutes > 0) {
      await ReadingTracker.addReadingSession(minutes);
    }

    if (!mounted) return;

    setState(() {
      isReading = false;
      elapsedSeconds = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reading session saved: '
          '$minutes minute${minutes == 1 ? '' : 's'}',
        ),
      ),
    );
  }

  // --------------------------------------------------
  // EDIT BOOK
  // --------------------------------------------------
  void _showEditBookDialog() {
    final titleController = TextEditingController(text: currentBook.title);

    final authorController = TextEditingController(text: currentBook.author);

    final coverController = TextEditingController(text: currentBook.coverUrl);

    double newProgress = currentBook.progress;

    showDialog(
      context: context,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.offWhite,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Text(
                'Edit Book',

                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SizedBox(
                width: 450,

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // TITLE
                      TextField(
                        controller: titleController,

                        textInputAction: TextInputAction.next,

                        style: const TextStyle(color: AppColors.darkText),

                        decoration: _inputDecoration(
                          label: 'Book Title',

                          icon: Icons.menu_book_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // AUTHOR
                      TextField(
                        controller: authorController,

                        textInputAction: TextInputAction.next,

                        style: const TextStyle(color: AppColors.darkText),

                        decoration: _inputDecoration(
                          label: 'Author',

                          icon: Icons.person_outline_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // COVER URL
                      TextField(
                        controller: coverController,

                        keyboardType: TextInputType.url,

                        style: const TextStyle(color: AppColors.darkText),

                        decoration: _inputDecoration(
                          label: 'Cover Image URL',

                          icon: Icons.image_outlined,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerLeft,

                        child: Text(
                          'Reading Progress: '
                          '${(newProgress * 100).toInt()}%',

                          style: const TextStyle(
                            fontWeight: FontWeight.w600,

                            color: AppColors.darkText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Slider(
                        value: newProgress,

                        min: 0,
                        max: 1,
                        divisions: 20,

                        label: '${(newProgress * 100).toInt()}%',

                        onChanged: (value) {
                          setDialogState(() {
                            newProgress = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },

                  child: const Text('Cancel'),
                ),

                FilledButton.icon(
                  onPressed: () {
                    final title = titleController.text.trim();

                    final author = authorController.text.trim();

                    if (title.isEmpty || author.isEmpty) {
                      return;
                    }

                    setState(() {
                      currentBook = currentBook.copyWith(
                        title: title,

                        author: author,

                        coverUrl: coverController.text.trim(),

                        progress: newProgress,
                      );
                    });

                    Navigator.pop(dialogContext);
                  },

                  icon: const Icon(Icons.save_rounded),

                  label: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      authorController.dispose();
      coverController.dispose();
    });
  }

  // --------------------------------------------------
  // DELETE BOOK
  // --------------------------------------------------
  void _showDeleteDialog() {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.offWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Delete Book',

            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Are you sure you want to delete '
            '"${currentBook.title}"?',

            style: const TextStyle(color: AppColors.darkText, height: 1.4),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('Cancel'),
            ),

            FilledButton.icon(
              onPressed: () {
                // Confirmation dialog close.
                Navigator.pop(dialogContext);

                // Library එකට delete result return.
                Navigator.pop(context, {
                  'action': 'delete',
                  'book': currentBook,
                });
              },

              icon: const Icon(Icons.delete_rounded),

              label: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // BACK WITH UPDATED BOOK
  // --------------------------------------------------
  void _goBack() {
    // Book එක edit වෙලා තිබුණත්
    // latest version එක Library/Home එකට return.
    Navigator.pop(context, {'action': 'update', 'book': currentBook});
  }

  @override
  Widget build(BuildContext context) {
    final String status = currentBook.progress >= 1
        ? 'Completed'
        : currentBook.progress > 0
        ? 'Currently Reading'
        : 'Want to Read';

    return PopScope(
      // System/browser back එකත්
      // _goBack() හරහා යවනවා.
      canPop: false,

      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBack();
        }
      },

      child: Scaffold(
        backgroundColor: Colors.transparent,

        // --------------------------------------------------
        // APP BAR
        // --------------------------------------------------
        appBar: AppBar(
          backgroundColor: AppColors.offWhite.withValues(alpha: 0.96),

          elevation: 0,

          title: const Text(
            'Book Details',

            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Proper back button.
          leading: IconButton(
            tooltip: 'Back',

            onPressed: _goBack,

            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.darkText,
            ),
          ),

          // User-added books වලට
          // Edit/Delete options.
          actions: widget.canModify
              ? [
                  IconButton(
                    tooltip: 'Edit Book',

                    onPressed: _showEditBookDialog,

                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.darkText,
                    ),
                  ),

                  IconButton(
                    tooltip: 'Delete Book',

                    onPressed: _showDeleteDialog,

                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.darkText,
                    ),
                  ),

                  const SizedBox(width: 8),
                ]
              : null,
        ),

        body: SafeArea(
          child: BooklyBackground(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),

                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),

                  child: Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(24),

                    decoration: _cardDecoration(),

                    child: Column(
                      children: [
                        // --------------------------------------------------
                        // BOOK COVER
                        // --------------------------------------------------
                        Container(
                          padding: const EdgeInsets.all(6),

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.80),

                            borderRadius: BorderRadius.circular(16),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),

                                blurRadius: 12,

                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),

                            child: currentBook.coverUrl.isEmpty
                                ? _coverPlaceholder()
                                : Image.network(
                                    currentBook.coverUrl,

                                    width: 160,
                                    height: 230,

                                    fit: BoxFit.cover,

                                    errorBuilder: (context, error, stackTrace) {
                                      return _coverPlaceholder();
                                    },
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --------------------------------------------------
                        // TITLE
                        // --------------------------------------------------
                        Text(
                          currentBook.title,

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 26,

                            fontWeight: FontWeight.bold,

                            color: AppColors.darkText,

                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // --------------------------------------------------
                        // AUTHOR
                        // --------------------------------------------------
                        Text(
                          currentBook.author,

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 16,

                            color: AppColors.darkText.withValues(alpha: 0.72),
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Divider(),

                        const SizedBox(height: 20),

                        // --------------------------------------------------
                        // READING PROGRESS
                        // --------------------------------------------------
                        const Align(
                          alignment: Alignment.centerLeft,

                          child: Text(
                            'Reading Progress',

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                              color: AppColors.darkText,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),

                          child: LinearProgressIndicator(
                            value: currentBook.progress,

                            minHeight: 9,

                            backgroundColor: AppColors.sage.withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),

                        const SizedBox(height: 9),

                        Align(
                          alignment: Alignment.centerRight,

                          child: Text(
                            '${(currentBook.progress * 100).toInt()}% completed',

                            style: const TextStyle(
                              fontSize: 14,

                              fontWeight: FontWeight.w500,

                              color: AppColors.darkText,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --------------------------------------------------
                        // STATUS
                        // --------------------------------------------------
                        const Align(
                          alignment: Alignment.centerLeft,

                          child: Text(
                            'Status',

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                              color: AppColors.darkText,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerLeft,

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),

                              color: AppColors.sage.withValues(alpha: 0.35),
                            ),

                            child: Text(
                              status,

                              style: const TextStyle(
                                fontSize: 14,

                                fontWeight: FontWeight.w600,

                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // --------------------------------------------------
                        // READING SESSION
                        // --------------------------------------------------
                        const Align(
                          alignment: Alignment.centerLeft,

                          child: Text(
                            'Reading Session',

                            style: TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                              color: AppColors.darkText,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),

                            color: AppColors.sage.withValues(alpha: 0.25),

                            border: Border.all(
                              color: AppColors.sage.withValues(alpha: 0.45),
                            ),
                          ),

                          child: Column(
                            children: [
                              const Icon(
                                Icons.auto_stories_rounded,

                                size: 30,

                                color: AppColors.primary,
                              ),

                              const SizedBox(height: 8),

                              // TIMER
                              Text(
                                '${(elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:'
                                '${(elapsedSeconds % 60).toString().padLeft(2, '0')}',

                                style: const TextStyle(
                                  fontSize: 34,

                                  fontWeight: FontWeight.bold,

                                  color: AppColors.darkText,
                                ),
                              ),

                              const SizedBox(height: 14),

                              SizedBox(
                                width: double.infinity,

                                child: FilledButton.icon(
                                  onPressed: isReading
                                      ? _finishReadingSession
                                      : _startReadingSession,

                                  icon: Icon(
                                    isReading
                                        ? Icons.stop_rounded
                                        : Icons.play_arrow_rounded,
                                  ),

                                  label: Text(
                                    isReading
                                        ? 'Finish Session'
                                        : 'Start Reading',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // COVER PLACEHOLDER
  // --------------------------------------------------
  Widget _coverPlaceholder() {
    return Container(
      width: 160,
      height: 230,

      color: AppColors.sage.withValues(alpha: 0.30),

      child: const Icon(
        Icons.menu_book_rounded,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  // --------------------------------------------------
  // INPUT DESIGN
  // --------------------------------------------------
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon, color: AppColors.primary),

      filled: true,

      fillColor: Colors.white.withValues(alpha: 0.86),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: BorderSide(color: AppColors.sage.withValues(alpha: 0.55)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  // --------------------------------------------------
  // MAIN CARD DESIGN
  // --------------------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.offWhite.withValues(alpha: 0.97),

      borderRadius: BorderRadius.circular(20),

      border: Border.all(color: Colors.white.withValues(alpha: 0.65)),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),

          blurRadius: 14,

          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
