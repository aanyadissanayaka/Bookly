import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';
import '../widgets/bookly_background.dart';

class NotesQuotesScreen extends StatefulWidget {
  const NotesQuotesScreen({super.key});

  @override
  State<NotesQuotesScreen> createState() => _NotesQuotesScreenState();
}

class _NotesQuotesScreenState extends State<NotesQuotesScreen> {
  // User save කරන notes.
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // --------------------------------------------------
  // LOAD SAVED NOTES
  // --------------------------------------------------
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final savedNotes = prefs.getStringList('bookly_notes') ?? [];

    if (!mounted) return;

    setState(() {
      notes = savedNotes;
    });
  }

  // --------------------------------------------------
  // SAVE NOTES
  // --------------------------------------------------
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('bookly_notes', notes);
  }

  // --------------------------------------------------
  // ADD NEW NOTE
  // --------------------------------------------------
  Future<void> _addNote({
    required String note,
    required BuildContext dialogContext,
  }) async {
    final cleanedNote = note.trim();

    // Empty note එකක් save කරන්නේ නැහැ.
    if (cleanedNote.isEmpty) {
      return;
    }

    setState(() {
      notes.add(cleanedNote);
    });

    // Local storage එකට save කරනවා.
    await _saveNotes();

    if (!dialogContext.mounted) return;

    // Save වුණාට පස්සේ dialog එක close කරනවා.
    Navigator.pop(dialogContext);
  }

  // --------------------------------------------------
  // ADD NOTE DIALOG
  // --------------------------------------------------
  void _showAddNoteDialog() {
    final TextEditingController noteController = TextEditingController();

    final FocusNode noteFocusNode = FocusNode();

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.offWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.primary),

              SizedBox(width: 10),

              Text(
                'Add Note',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          content: SizedBox(
            width: 420,

            child: CallbackShortcuts(
              bindings: {
                // ENTER = SAVE
                const SingleActivator(LogicalKeyboardKey.enter): () {
                  _addNote(
                    note: noteController.text,
                    dialogContext: dialogContext,
                  );
                },
              },

              child: Focus(
                autofocus: true,

                child: TextField(
                  controller: noteController,

                  focusNode: noteFocusNode,

                  // Shift + Enter use කරලා
                  // multiline note එකක් ලියන්න පුළුවන්.
                  maxLines: 5,
                  minLines: 3,

                  textInputAction: TextInputAction.newline,

                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.darkText,
                    height: 1.4,
                  ),

                  decoration: InputDecoration(
                    hintText: 'Write your note or quote...',

                    hintStyle: TextStyle(
                      color: AppColors.darkText.withValues(alpha: 0.50),
                    ),

                    filled: true,

                    fillColor: Colors.white.withValues(alpha: 0.85),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),

                      borderSide: BorderSide(
                        color: AppColors.sage.withValues(alpha: 0.55),
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),

                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
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
              onPressed: () async {
                await _addNote(
                  note: noteController.text,
                  dialogContext: dialogContext,
                );
              },

              icon: const Icon(Icons.save_rounded),

              label: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      noteController.dispose();
      noteFocusNode.dispose();
    });
  }

  // --------------------------------------------------
  // DELETE NOTE
  // --------------------------------------------------
  Future<void> _deleteNote(int index) async {
    setState(() {
      notes.removeAt(index);
    });

    await _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // --------------------------------------------------
      // ADD NOTE BUTTON
      // --------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteDialog,

        icon: const Icon(Icons.add_rounded),

        label: const Text('Add Note'),
      ),

      body: SafeArea(
        child: BooklyBackground(
          child: Center(
            child: ConstrainedBox(
              // Web එකේ content එක
              // වැඩිය stretch වෙන්නේ නැහැ.
              constraints: const BoxConstraints(maxWidth: 900),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // --------------------------------------------------
                    // SCREEN TITLE
                    // --------------------------------------------------
                    const Text(
                      'Notes & Quotes',

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Save thoughts and quotes from your reading.',

                      style: TextStyle(
                        fontSize: 15,

                        color: AppColors.darkText.withValues(alpha: 0.75),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --------------------------------------------------
                    // NOTES LIST
                    // --------------------------------------------------
                    Expanded(
                      child: notes.isEmpty
                          // ------------------------------------------
                          // EMPTY STATE
                          // ------------------------------------------
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                  vertical: 30,
                                ),

                                decoration: _cardDecoration(),

                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    Icon(
                                      Icons.edit_note_rounded,
                                      size: 60,
                                      color: AppColors.primary,
                                    ),

                                    SizedBox(height: 12),

                                    Text(
                                      'No notes yet',

                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkText,
                                      ),
                                    ),

                                    SizedBox(height: 6),

                                    Text(
                                      'Add your first note or quote.',

                                      textAlign: TextAlign.center,

                                      style: TextStyle(
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          // ------------------------------------------
                          // SAVED NOTES
                          // ------------------------------------------
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 90),

                              itemCount: notes.length,

                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 12);
                              },

                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.all(16),

                                  decoration: _cardDecoration(),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),

                                        decoration: BoxDecoration(
                                          color: AppColors.sage.withValues(
                                            alpha: 0.30,
                                          ),

                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),

                                        child: const Icon(
                                          Icons.format_quote_rounded,

                                          color: AppColors.primary,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Text(
                                          notes[index],

                                          style: const TextStyle(
                                            fontSize: 16,

                                            height: 1.45,

                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      IconButton(
                                        tooltip: 'Delete note',

                                        onPressed: () async {
                                          await _deleteNote(index);
                                        },

                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                        ),

                                        color: AppColors.darkText,
                                      ),
                                    ],
                                  ),
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
  // REUSABLE NOTE CARD DESIGN
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
