import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color background = Colors.white;
}

class AppTextStyles {
  static const TextStyle header = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle subHeader = TextStyle(
    fontSize: 14,
    color: AppColors.textGrey,
    height: 1.5,
  );
}
