// Flutter Material Design widgets භාවිතා කරන්න.
import 'package:flutter/material.dart';


// BookProgressBar කියන්නේ පොතක reading progress එක
// bar එකක් විදිහට පෙන්වන reusable widget එක.
class BookProgressBar extends StatelessWidget {

  // Reading progress value එක store කරන variable එක.
  //
  // 0.0 = 0%
  // 0.5 = 50%
  // 1.0 = 100%
  final double progress;


  // BookProgressBar එක create කරන constructor එක.
  const BookProgressBar({
    super.key,

    // Progress value එක අනිවාර්යයෙන් ලබා දෙන්න ඕන.
    required this.progress,
  });


  @override
  Widget build(BuildContext context) {

    // Column එකෙන් progress bar එකයි
    // percentage text එකයි උඩින් පහළට arrange කරනවා.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        // Flutter එකේ built-in horizontal progress bar එක.
        LinearProgressIndicator(

          // 0.0 සිට 1.0 දක්වා value එකක් ලබා දෙනවා.
          value: progress,

          // Progress bar එකේ height එක.
          minHeight: 6,

          // Bar එකේ corners round කරනවා.
          borderRadius: BorderRadius.circular(10),
        ),

        const SizedBox(height: 6),

        // Decimal progress එක percentage එකක් බවට පත් කරනවා.
        Text(
          '${(progress * 100).round()}% completed',

          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}