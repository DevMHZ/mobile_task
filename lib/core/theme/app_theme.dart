import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'app_typography.dart';

abstract final class AppColors {
  static const blue = Color(0xFF0061FF);
  static const ink = Color(0xFF191D31);
  static const favorite = Color(0xFFFF385C);
  static const favoriteOnDark = Color(0xFFFF385C);
  static const success = Color(0xFF237A57);
  static const destructive = Color(0xFFB3261E);
  static const muted = Color(0xFF666876);
  static const canvas = Color(0xFFFFFFFF);
  static const line = Color(0xFFE8EEF9);
  static const paleBlue = Color(0xFFF4F8FF);
  static const skeleton = Color(0xFFE8EDF4);
}

abstract final class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const page = 20.0;
  static const radius = 12.0;
  static const dialogWidth = 400.0;
  static const dialogThumbnail = 64.0;
  static const controlRadius = 8.0;
  static const maxWidth = 1100.0;
  static const gridBreakpoint = 600.0;
  static const cardMinWidth = 160.0;
  static const bottomActionClearance = 80.0;
  static const formWidth = 640.0;
  static const descriptionMinLines = 3;
  static const descriptionMaxLines = 6;
  static const imageRatio = 1.65;
}

abstract final class AppTheme {
  static ThemeData light({Locale locale = const Locale('en')}) {
    final fontFamily = AppTypography.familyFor(locale);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      error: AppColors.destructive,
      secondary: AppColors.blue,
      secondaryContainer: AppColors.paleBlue,
      onSecondaryContainer: AppColors.blue,
      tertiary: AppColors.blue,
      tertiaryContainer: AppColors.paleBlue,
      surface: Colors.white,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      outlineVariant: AppColors.line,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: fontFamily,
    );
    return base.copyWith(
      textTheme: base.textTheme
          .copyWith(
            headlineLarge: const TextStyle(
              fontSize: 34,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            headlineSmall: const TextStyle(
              fontSize: 25,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            titleLarge: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            bodyMedium: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              height: 1.65,
            ),
          )
          .apply(
            fontFamily: fontFamily,
            bodyColor: AppColors.ink,
            displayColor: AppColors.ink,
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFC),
        contentPadding: const EdgeInsets.all(AppSpace.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.controlRadius),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.controlRadius),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          animationDuration: AppConfig.motion,
          minimumSize: const Size(48, 52),
          shape: const StadiumBorder(),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          animationDuration: AppConfig.motion,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpace.controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          animationDuration: AppConfig.motion,
          minimumSize: const Size(48, 48),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: AppColors.line),
        backgroundColor: AppColors.paleBlue,
        selectedColor: AppColors.blue,
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.ink,
          fontSize: 13,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.paleBlue,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.canvas,
        showDragHandle: true,
        modalBarrierColor: Color(0x6615243B),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.canvas,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          fontFamily: fontFamily,
          color: AppColors.ink,
        ),
        closeIconColor: AppColors.muted,
        showCloseIcon: true,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpace.lg),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpace.xl),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: const Color(0x29000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      dividerColor: AppColors.line,
    );
  }
}

/// Measurements inspected from the blue Figma frames (430px artboard).
abstract final class DesignMetrics {
  static const cardTitleSize = 14.0;
  static const cardCategorySize = 11.0;
  static const cardLineHeight = 1.4;
  static const minimumTapTarget = 48.0;
  static const largeTextThreshold = 1.6;
  static const featuredCount = 5;
  static const recommendationCount = 4;
  static const histogramBins = 24;
  static const histogramHeight = 64.0;
  static const featuredRadius = 24.0;
  static const featuredWidth = 250.0;
  static const featuredHeight = 340.0;
  static const featuredGap = 20.0;
  static const gridGap = 16.0;
  static const gridImageRatio = 1.0;
  static const listImageSize = 100.0;
  static const searchHeight = 56.0;
  static const avatarSize = 44.0;
  static const profileAvatarSize = 120.0;
  static const navigationHeight = 64.0;
  static const detailImageRatio = 1.0;
  static const dotSize = 6.0;
  static const activeDotWidth = 24.0;
  static const sheetHeightFraction = .85;
  static const star = Color(0xFFFFA500);
  static const cardShadow = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}

/// Shared interaction values, independent of the resting Figma appearance.
abstract final class InteractionTokens {
  static const surfacePressedOpacity = .10;
  static const surfaceHoverOpacity = .04;
  static const navigationPressedOpacity = .14;
  static const navigationHoverOpacity = .06;
  static const navigationIconSize = 24.0;
  static const navigationLabelSize = 12.0;
}
