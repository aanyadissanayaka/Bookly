import 'package:flutter/material.dart';

import '../models/book.dart';
import '../utils/app_colors.dart';
import '../widgets/bookly_background.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _authorController = TextEditingController();

  final TextEditingController _coverController = TextEditingController();

  double _progress = 0.0;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _coverController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // SAVE BOOK
  // --------------------------------------------------
  void _saveBook() {
    final title = _titleController.text.trim();

    final author = _authorController.text.trim();

    final coverUrl = _coverController.text.trim();

    // Title සහ Author අනිවාර්යයි.
    if (title.isEmpty || author.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the book title and author.'),
        ),
      );

      return;
    }

    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),

      title: title,
      author: author,
      coverUrl: coverUrl,
      progress: _progress,
    );

    // New Book object එක Library screen එකට
    // return කරනවා.
    Navigator.pop(context, newBook);
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _coverController.text.trim();

    return Scaffold(
      backgroundColor: Colors.transparent,

      // --------------------------------------------------
      // APP BAR + BACK BUTTON
      // --------------------------------------------------
      appBar: AppBar(
        backgroundColor: AppColors.offWhite.withValues(alpha: 0.96),

        elevation: 0,

        leading: IconButton(
          tooltip: 'Back',

          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Add Book',

          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: BooklyBackground(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),

              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(22),

                  decoration: _cardDecoration(),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // --------------------------------------------------
                      // HEADER
                      // --------------------------------------------------
                      const Row(
                        children: [
                          Icon(
                            Icons.library_add_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),

                          SizedBox(width: 10),

                          Text(
                            'Book Details',

                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Add a book to your personal library.',

                        style: TextStyle(
                          fontSize: 14,

                          color: AppColors.darkText.withValues(alpha: 0.68),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // --------------------------------------------------
                      // TITLE
                      // --------------------------------------------------
                      TextField(
                        controller: _titleController,

                        textInputAction: TextInputAction.next,

                        style: const TextStyle(color: AppColors.darkText),

                        decoration: _inputDecoration(
                          label: 'Book Title',

                          hint: 'Enter the book title',

                          icon: Icons.menu_book_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --------------------------------------------------
                      // AUTHOR
                      // --------------------------------------------------
                      TextField(
                        controller: _authorController,

                        textInputAction: TextInputAction.next,

                        style: const TextStyle(color: AppColors.darkText),

                        decoration: _inputDecoration(
                          label: 'Author',

                          hint: 'Enter the author name',

                          icon: Icons.person_outline_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --------------------------------------------------
                      // COVER URL
                      // --------------------------------------------------
                      TextField(
                        controller: _coverController,

                        keyboardType: TextInputType.url,

                        textInputAction: TextInputAction.done,

                        style: const TextStyle(color: AppColors.darkText),

                        // URL type කරනකොට
                        // preview refresh කරනවා.
                        onChanged: (value) {
                          setState(() {});
                        },

                        decoration: _inputDecoration(
                          label: 'Cover Image URL',

                          hint: 'Optional — paste an image URL',

                          icon: Icons.image_outlined,
                        ),
                      ),

                      // --------------------------------------------------
                      // COVER PREVIEW
                      // --------------------------------------------------
                      if (coverUrl.isNotEmpty) ...[
                        const SizedBox(height: 22),

                        const Text(
                          'Cover Preview',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),

                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),

                              borderRadius: BorderRadius.circular(14),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),

                                  blurRadius: 10,

                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),

                              child: Image.network(
                                coverUrl,

                                width: 130,
                                height: 190,

                                fit: BoxFit.cover,

                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 130,
                                    height: 190,

                                    color: AppColors.sage.withValues(
                                      alpha: 0.30,
                                    ),

                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,

                                          size: 42,

                                          color: AppColors.primary,
                                        ),

                                        SizedBox(height: 8),

                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),

                                          child: Text(
                                            'Invalid image URL',

                                            textAlign: TextAlign.center,

                                            style: TextStyle(
                                              fontSize: 13,

                                              color: AppColors.darkText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      const Divider(),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // READING PROGRESS
                      // --------------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            'Reading Progress',

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: AppColors.sage.withValues(alpha: 0.30),

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              '${(_progress * 100).toInt()}%',

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,

                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Slider(
                        value: _progress,
                        min: 0,
                        max: 1,
                        divisions: 20,

                        label: '${(_progress * 100).toInt()}%',

                        onChanged: (value) {
                          setState(() {
                            _progress = value;
                          });
                        },
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            'Not started',

                            style: TextStyle(
                              fontSize: 12,

                              color: AppColors.darkText.withValues(alpha: 0.60),
                            ),
                          ),

                          Text(
                            'Completed',

                            style: TextStyle(
                              fontSize: 12,

                              color: AppColors.darkText.withValues(alpha: 0.60),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // --------------------------------------------------
                      // ADD BOOK BUTTON
                      // --------------------------------------------------
                      SizedBox(
                        width: double.infinity,

                        child: FilledButton.icon(
                          onPressed: _saveBook,

                          icon: const Icon(Icons.add_rounded),

                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),

                            child: Text(
                              'Add Book',

                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
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
  // INPUT DESIGN
  // --------------------------------------------------
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

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
