import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/book_storage.dart';
import '../data/mock_books.dart';
import '../data/reading_tracker.dart';
import '../utils/app_colors.dart';
import '../widgets/bookly_background.dart';

import 'preferences_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --------------------------------------------------
  // PROFILE DATA
  // --------------------------------------------------

  String readerName = 'Bookly Reader';

  Uint8List? profileImageBytes;

  final ImagePicker _picker = ImagePicker();

  // --------------------------------------------------
  // READING STATISTICS
  // --------------------------------------------------

  int booksRead = 0;
  int readingStreak = 0;
  int notesCount = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // --------------------------------------------------
  // LOAD PROFILE + STATISTICS
  // --------------------------------------------------
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    // Saved reader name.
    final savedName = prefs.getString('reader_name');

    // Saved profile photo.
    final savedProfileImage = prefs.getString('profile_image');

    // Saved notes.
    final savedNotes = prefs.getStringList('bookly_notes') ?? [];

    // User add කරපු books.
    final savedBooks = await BookStorage.loadBooks();

    // Sample books + user books.
    final allBooks = [...mockBooks, ...savedBooks];

    // 100% complete books ගණන.
    final completedBooks = allBooks.where((book) {
      return book.progress >= 1;
    }).length;

    // Actual reading streak.
    final savedStreak = await ReadingTracker.getStreak();

    // Profile image Base64 -> bytes.
    Uint8List? loadedImage;

    if (savedProfileImage != null && savedProfileImage.isNotEmpty) {
      try {
        loadedImage = base64Decode(savedProfileImage);
      } catch (e) {
        loadedImage = null;
      }
    }

    if (!mounted) return;

    setState(() {
      if (savedName != null && savedName.isNotEmpty) {
        readerName = savedName;
      }

      profileImageBytes = loadedImage;

      booksRead = completedBooks;
      readingStreak = savedStreak;
      notesCount = savedNotes.length;

      isLoading = false;
    });
  }

  // --------------------------------------------------
  // PICK + SAVE PROFILE IMAGE
  // --------------------------------------------------
  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 75,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    final encodedImage = base64Encode(bytes);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_image', encodedImage);

    if (!mounted) return;

    setState(() {
      profileImageBytes = bytes;
    });
  }

  // --------------------------------------------------
  // SAVE PROFILE NAME
  // --------------------------------------------------
  Future<void> _saveReaderName(String name) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('reader_name', name);
  }

  // --------------------------------------------------
  // EDIT PROFILE
  // --------------------------------------------------
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: readerName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.offWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SizedBox(
            width: 400,

            child: TextField(
              controller: nameController,

              autofocus: true,

              style: const TextStyle(color: AppColors.darkText),

              decoration: InputDecoration(
                labelText: 'Reader Name',

                filled: true,

                fillColor: Colors.white.withValues(alpha: 0.85),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),

              // Enter press කළාම name save.
              onSubmitted: (value) async {
                final newName = value.trim();

                if (newName.isEmpty) {
                  return;
                }

                await _saveReaderName(newName);

                if (!mounted) return;

                setState(() {
                  readerName = newName;
                });

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
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
                final newName = nameController.text.trim();

                if (newName.isEmpty) {
                  return;
                }

                await _saveReaderName(newName);

                if (!mounted) return;

                setState(() {
                  readerName = newName;
                });

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },

              icon: const Icon(Icons.save_rounded),

              label: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameController.dispose();
    });
  }

  // --------------------------------------------------
  // OPEN PREFERENCES
  // --------------------------------------------------
  Future<void> _openPreferences() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PreferencesScreen()),
    );

    await _loadProfileData();
  }

  // --------------------------------------------------
  // ABOUT BOOKLY
  // --------------------------------------------------
  void _showAboutDialog() {
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
              Icon(Icons.menu_book_rounded, color: AppColors.primary),

              SizedBox(width: 10),

              Text(
                'About Bookly',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          content: const SizedBox(
            width: 400,

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Bookly is a personal reading companion designed to help '
                  'you organize books, track reading progress, save notes, '
                  'and build better reading habits.',
                  style: TextStyle(color: AppColors.darkText, height: 1.5),
                ),

                SizedBox(height: 20),

                Divider(),

                SizedBox(height: 12),

                Text(
                  'Bookly v1.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Designed & Developed by Aanya Dissanayaka',
                  style: TextStyle(color: AppColors.darkText),
                ),

                SizedBox(height: 6),

                Text(
                  '© 2026 Aanya Dissanayaka',
                  style: TextStyle(color: AppColors.darkText),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------
    // LOADING
    // --------------------------------------------------
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,

        body: SafeArea(
          child: BooklyBackground(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: SafeArea(
        child: BooklyBackground(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),

              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // --------------------------------------------------
                    // PROFILE TITLE
                    // --------------------------------------------------
                    const Text(
                      'Profile',

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --------------------------------------------------
                    // PROFILE CARD
                    // --------------------------------------------------
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),

                      decoration: _cardDecoration(),

                      child: Center(
                        child: Column(
                          children: [
                            // PROFILE IMAGE
                            GestureDetector(
                              onTap: _pickProfileImage,

                              child: Stack(
                                clipBehavior: Clip.none,

                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),

                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,

                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),

                                    child: CircleAvatar(
                                      radius: 48,

                                      backgroundColor: AppColors.sage
                                          .withValues(alpha: 0.35),

                                      backgroundImage: profileImageBytes != null
                                          ? MemoryImage(profileImageBytes!)
                                          : null,

                                      child: profileImageBytes == null
                                          ? const Icon(
                                              Icons.person_rounded,
                                              size: 55,
                                              color: AppColors.primary,
                                            )
                                          : null,
                                    ),
                                  ),

                                  Positioned(
                                    right: -2,
                                    bottom: -2,

                                    child: Container(
                                      padding: const EdgeInsets.all(8),

                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),

                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              readerName,

                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Keep turning the pages 📚',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                fontSize: 14,

                                color: AppColors.darkText.withValues(
                                  alpha: 0.70,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            OutlinedButton.icon(
                              onPressed: _showEditProfileDialog,

                              icon: const Icon(Icons.edit_rounded, size: 18),

                              label: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // --------------------------------------------------
                    // STATISTICS
                    // --------------------------------------------------
                    const Text(
                      'Reading Statistics',

                      style: TextStyle(
                        fontSize: 20,
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
                            icon: Icons.local_fire_department_rounded,

                            value: readingStreak.toString(),

                            label: 'Day Streak',
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

                    const SizedBox(height: 32),

                    // --------------------------------------------------
                    // SETTINGS
                    // --------------------------------------------------
                    const Text(
                      'Settings',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // EDIT PROFILE
                    _settingsTile(
                      icon: Icons.person_outline_rounded,

                      title: 'Edit Profile',

                      onTap: _showEditProfileDialog,
                    ),

                    const SizedBox(height: 10),

                    // PREFERENCES
                    _settingsTile(
                      icon: Icons.tune_rounded,

                      title: 'Preferences',

                      subtitle: 'Reading goals, reminders and appearance',

                      onTap: _openPreferences,
                    ),

                    const SizedBox(height: 10),

                    // ABOUT
                    _settingsTile(
                      icon: Icons.info_outline_rounded,

                      title: 'About Bookly',

                      onTap: _showAboutDialog,
                    ),

                    const SizedBox(height: 24),
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
  // SETTINGS TILE
  // --------------------------------------------------
  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: _cardDecoration(),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),

        leading: Container(
          padding: const EdgeInsets.all(9),

          decoration: BoxDecoration(
            color: AppColors.sage.withValues(alpha: 0.30),

            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(icon, color: AppColors.primary),
        ),

        title: Text(
          title,

          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),

        subtitle: subtitle != null
            ? Text(
                subtitle,

                style: TextStyle(
                  color: AppColors.darkText.withValues(alpha: 0.65),
                ),
              )
            : null,

        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.primary,
        ),

        onTap: onTap,
      ),
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

      decoration: _cardDecoration(),

      child: Column(
        children: [
          Icon(icon, size: 27, color: AppColors.primary),

          const SizedBox(height: 7),

          Text(
            value,

            style: const TextStyle(
              fontSize: 20,
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
  // COMMON CARD DESIGN
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
