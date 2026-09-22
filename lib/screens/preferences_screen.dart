import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';
import '../widgets/bookly_background.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool remindersEnabled = true;
  int dailyGoal = 20;
  String appearance = 'System';
  String defaultReadingStatus = 'Want to Read';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // --------------------------------------------------
  // LOAD SAVED PREFERENCES
  // --------------------------------------------------
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final savedReminders = prefs.getBool('reading_reminders');

    final savedGoal = prefs.getInt('daily_reading_goal');

    final savedAppearance = prefs.getString('appearance_mode');

    final savedStatus = prefs.getString('default_reading_status');

    if (!mounted) return;

    setState(() {
      remindersEnabled = savedReminders ?? true;
      dailyGoal = savedGoal ?? 20;
      appearance = savedAppearance ?? 'System';
      defaultReadingStatus = savedStatus ?? 'Want to Read';
    });
  }

  // --------------------------------------------------
  // SAVE REMINDERS
  // --------------------------------------------------
  Future<void> _saveReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('reading_reminders', value);
  }

  // --------------------------------------------------
  // SAVE DAILY GOAL
  // --------------------------------------------------
  Future<void> _saveDailyGoal(int value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('daily_reading_goal', value);
  }

  // --------------------------------------------------
  // SAVE APPEARANCE
  // --------------------------------------------------
  Future<void> _saveAppearance(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('appearance_mode', value);
  }

  // --------------------------------------------------
  // SAVE DEFAULT STATUS
  // --------------------------------------------------
  Future<void> _saveDefaultStatus(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('default_reading_status', value);
  }

  // --------------------------------------------------
  // RESET PREFERENCES
  // --------------------------------------------------
  Future<void> _resetPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('reading_reminders');
    await prefs.remove('daily_reading_goal');
    await prefs.remove('appearance_mode');
    await prefs.remove('default_reading_status');

    if (!mounted) return;

    setState(() {
      remindersEnabled = true;
      dailyGoal = 20;
      appearance = 'System';
      defaultReadingStatus = 'Want to Read';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences reset to default.')),
    );
  }

  // --------------------------------------------------
  // RESET CONFIRMATION
  // --------------------------------------------------
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.offWhite,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Reset Preferences',
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            'Are you sure you want to reset all preferences '
            'to their default values?',
            style: TextStyle(color: AppColors.darkText, height: 1.4),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _resetPreferences();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // --------------------------------------------------
      // TOP BAR + BACK BUTTON
      // --------------------------------------------------
      appBar: AppBar(
        backgroundColor: AppColors.offWhite.withValues(alpha: 0.96),

        elevation: 0,

        // Profile -> Preferences ලෙස Navigator.push
        // කරලා ආපු නිසා මේ arrow එක Profile එකට ආපහු යනවා.
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Preferences',
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
              constraints: const BoxConstraints(maxWidth: 750),

              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // --------------------------------------------------
                    // READING SECTION
                    // --------------------------------------------------
                    const Text(
                      'Reading',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // --------------------------------------------------
                    // READING REMINDERS
                    // --------------------------------------------------
                    Container(
                      decoration: _cardDecoration(),

                      child: SwitchListTile(
                        secondary: _settingIcon(
                          Icons.notifications_none_rounded,
                        ),

                        title: const Text(
                          'Reading Reminders',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),

                        subtitle: Text(
                          'Get reminders to keep your reading habit going.',
                          style: TextStyle(
                            color: AppColors.darkText.withValues(alpha: 0.65),
                          ),
                        ),

                        value: remindersEnabled,

                        onChanged: (value) async {
                          setState(() {
                            remindersEnabled = value;
                          });

                          await _saveReminders(value);
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --------------------------------------------------
                    // DAILY READING GOAL
                    // --------------------------------------------------
                    Container(
                      decoration: _cardDecoration(),

                      child: ListTile(
                        leading: _settingIcon(Icons.timer_outlined),

                        title: const Text(
                          'Daily Reading Goal',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),

                        subtitle: Text(
                          '$dailyGoal minutes per day',
                          style: TextStyle(
                            color: AppColors.darkText.withValues(alpha: 0.65),
                          ),
                        ),

                        trailing: DropdownButton<int>(
                          value: dailyGoal,
                          underline: const SizedBox(),

                          items: const [
                            DropdownMenuItem(value: 10, child: Text('10 min')),
                            DropdownMenuItem(value: 20, child: Text('20 min')),
                            DropdownMenuItem(value: 30, child: Text('30 min')),
                            DropdownMenuItem(value: 45, child: Text('45 min')),
                            DropdownMenuItem(value: 60, child: Text('60 min')),
                          ],

                          onChanged: (value) async {
                            if (value == null) return;

                            setState(() {
                              dailyGoal = value;
                            });

                            await _saveDailyGoal(value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --------------------------------------------------
                    // APP SECTION
                    // --------------------------------------------------
                    const Text(
                      'App',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // --------------------------------------------------
                    // APPEARANCE
                    // --------------------------------------------------
                    Container(
                      decoration: _cardDecoration(),

                      child: ListTile(
                        leading: _settingIcon(Icons.palette_outlined),

                        title: const Text(
                          'Appearance',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),

                        subtitle: Text(
                          appearance,
                          style: TextStyle(
                            color: AppColors.darkText.withValues(alpha: 0.65),
                          ),
                        ),

                        trailing: DropdownButton<String>(
                          value: appearance,
                          underline: const SizedBox(),

                          items: const [
                            DropdownMenuItem(
                              value: 'System',
                              child: Text('System'),
                            ),
                            DropdownMenuItem(
                              value: 'Light',
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: 'Dark',
                              child: Text('Dark'),
                            ),
                          ],

                          onChanged: (value) async {
                            if (value == null) return;

                            setState(() {
                              appearance = value;
                            });

                            await _saveAppearance(value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --------------------------------------------------
                    // DEFAULT READING STATUS
                    // --------------------------------------------------
                    Container(
                      decoration: _cardDecoration(),

                      child: ListTile(
                        leading: _settingIcon(Icons.bookmark_outline_rounded),

                        title: const Text(
                          'Default Reading Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),

                        subtitle: Text(
                          defaultReadingStatus,
                          style: TextStyle(
                            color: AppColors.darkText.withValues(alpha: 0.65),
                          ),
                        ),

                        trailing: DropdownButton<String>(
                          value: defaultReadingStatus,
                          underline: const SizedBox(),

                          items: const [
                            DropdownMenuItem(
                              value: 'Want to Read',
                              child: Text('Want to Read'),
                            ),
                            DropdownMenuItem(
                              value: 'Currently Reading',
                              child: Text('Currently Reading'),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Text('Completed'),
                            ),
                          ],

                          onChanged: (value) async {
                            if (value == null) return;

                            setState(() {
                              defaultReadingStatus = value;
                            });

                            await _saveDefaultStatus(value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --------------------------------------------------
                    // RESET
                    // --------------------------------------------------
                    SizedBox(
                      width: double.infinity,

                      child: OutlinedButton.icon(
                        onPressed: _showResetDialog,

                        icon: const Icon(Icons.restart_alt_rounded),

                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Reset Preferences'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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
  // SETTING ICON
  // --------------------------------------------------
  Widget _settingIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(9),

      decoration: BoxDecoration(
        color: AppColors.sage.withValues(alpha: 0.30),

        borderRadius: BorderRadius.circular(10),
      ),

      child: Icon(icon, color: AppColors.primary),
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
