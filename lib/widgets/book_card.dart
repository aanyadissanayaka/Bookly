// Flutter Material Design widgets භාවිතා කරන්න.
import 'package:flutter/material.dart';

// අපි හදපු reusable progress bar widget එක ලබාගන්නවා.
import 'progress_bar.dart';

// BookCard කියන්නේ Bookly app එකේ
// එක පොතක් card එකක් විදිහට පෙන්වන reusable widget එක.
class BookCard extends StatelessWidget {
  // පොතේ නම store කරන variable එක.
  final String title;

  // පොතේ කතුවරයාගේ නම store කරන variable එක.
  final String author;

  // පොතේ cover image එකේ internet URL එක store කරන variable එක.
  final String coverUrl;

  // මේ පොත user කොච්චර දුරට කියවලාද කියන value එක.
  final double progress;

  // BookCard එක create කරන constructor එක.
  const BookCard({
    super.key,

    // පොතේ නම අනිවාර්යයි.
    required this.title,

    // Author ගේ නම අනිවාර්යයි.
    required this.author,

    // Cover image URL එකත් අනිවාර්යයි.
    required this.coverUrl,

    // Reading progress එකත් BookCard එකට අනිවාර්යයෙන් ලබා දෙනවා.
    required this.progress,
  });

  // BookCard එකේ UI එක build කරන method එක.
  @override
  Widget build(BuildContext context) {
    // Card widget එකෙන් පොතේ details
    // card එකක් ඇතුළේ පෙන්වනවා.
    return Card(
      // Card එකේ corners round කරනවා.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      // Card එක ඇතුළේ content එකට space ලබා දෙනවා.
      child: Padding(
        padding: const EdgeInsets.all(12),

        // Column එකෙන් book details
        // උඩ ඉඳන් පහළට arrange කරනවා.
        child: Column(
          // Content එක වම් පැත්තට align කරනවා.
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Card එකේ ඉහළ කොටස book cover image එකට ලබා දෙනවා.
            Expanded(
              child: ClipRRect(
                // Cover image එකේ corners round කරනවා.
                borderRadius: BorderRadius.circular(12),

                // Internet URL එකකින් image එක load කරනවා.
                child: Image.network(
                  coverUrl,

                  // Image එක available width එක පුරා ගන්නවා.
                  width: double.infinity,

                  // Image එක තියෙන area එක cover වෙන විදිහට fit කරනවා.
                  fit: BoxFit.cover,

                  // Image එක load වෙන්නේ නැත්නම්
                  // fallback book icon එකක් පෙන්වනවා.
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.menu_book_rounded, size: 60),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // පොතේ නම පෙන්වනවා.
            Text(
              title,

              // Title එක දිග වැඩි නම් lines 2ක් විතරක් පෙන්වනවා.
              maxLines: 2,

              // ඉඩ මදි නම් අවසානයේ ... පෙන්වනවා.
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            // Author ගේ නම පෙන්වනවා.
            Text(
              author,

              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 10),

            // මේ BookCard එකට ලැබුණු progress value එක
            // අපි හදපු BookProgressBar widget එකට ලබා දෙනවා.
            BookProgressBar(progress: progress),
          ],
        ),
      ),
    );
  }
}
