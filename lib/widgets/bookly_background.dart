import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class BooklyBackground extends StatelessWidget {
  final Widget child;

  const BooklyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warmCream,
      child: child,
    );
  }
}
