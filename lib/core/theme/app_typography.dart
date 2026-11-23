import 'package:flutter/widgets.dart';

abstract final class AppTypography {
  static const englishFamily = 'Rubik';
  static const arabicFamily = 'IBMPlexSansArabic';

  static String familyFor(Locale locale) =>
      locale.languageCode == 'ar' ? arabicFamily : englishFamily;
}
