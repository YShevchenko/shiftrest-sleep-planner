import 'package:flutter/material.dart';

/// Design tokens extracted from Stitch designs.
/// Material 3 dark theme color palette.
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFFACC7FF);
  static const Color primaryContainer = Color(0xFF468FFF);
  static const Color onPrimary = Color(0xFF002F67);
  static const Color onPrimaryContainer = Color(0xFF00285A);
  static const Color primaryFixed = Color(0xFFD7E2FF);
  static const Color primaryFixedDim = Color(0xFFACC7FF);
  static const Color onPrimaryFixed = Color(0xFF001A40);
  static const Color onPrimaryFixedVariant = Color(0xFF004591);
  static const Color inversePrimary = Color(0xFF005CBD);

  // Secondary
  static const Color secondary = Color(0xFFB4C8E9);
  static const Color secondaryContainer = Color(0xFF374A66);
  static const Color onSecondary = Color(0xFF1D314C);
  static const Color onSecondaryContainer = Color(0xFFA6B9DA);
  static const Color secondaryFixed = Color(0xFFD4E3FF);
  static const Color secondaryFixedDim = Color(0xFFB4C8E9);
  static const Color onSecondaryFixed = Color(0xFF061C36);
  static const Color onSecondaryFixedVariant = Color(0xFF354863);

  // Tertiary
  static const Color tertiary = Color(0xFFFFB784);
  static const Color tertiaryContainer = Color(0xFFDF7306);
  static const Color onTertiary = Color(0xFF502500);
  static const Color onTertiaryContainer = Color(0xFF451F00);
  static const Color tertiaryFixed = Color(0xFFFFDCC6);
  static const Color tertiaryFixedDim = Color(0xFFFFB784);
  static const Color onTertiaryFixed = Color(0xFF301400);
  static const Color onTertiaryFixedVariant = Color(0xFF713700);

  // Error
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Surface
  static const Color surface = Color(0xFF111317);
  static const Color surfaceDim = Color(0xFF111317);
  static const Color surfaceBright = Color(0xFF37393E);
  static const Color surfaceContainerLowest = Color(0xFF0C0E12);
  static const Color surfaceContainerLow = Color(0xFF1A1C20);
  static const Color surfaceContainer = Color(0xFF1E2024);
  static const Color surfaceContainerHigh = Color(0xFF282A2E);
  static const Color surfaceContainerHighest = Color(0xFF333539);
  static const Color surfaceVariant = Color(0xFF333539);
  static const Color surfaceTint = Color(0xFFACC7FF);

  // On Surface
  static const Color onSurface = Color(0xFFE2E2E8);
  static const Color onSurfaceVariant = Color(0xFFC1C6D6);
  static const Color onBackground = Color(0xFFE2E2E8);

  // Inverse
  static const Color inverseSurface = Color(0xFFE2E2E8);
  static const Color inverseOnSurface = Color(0xFF2F3035);

  // Outline
  static const Color outline = Color(0xFF8B919F);
  static const Color outlineVariant = Color(0xFF414754);

  // Background
  static const Color background = Color(0xFF111317);

  // Dark Room mode colors
  static const Color darkRoomBackground = Color(0xFF000000);
  static const Color darkRoomRed = Color(0xFF7F1D1D);
  static const Color darkRoomRedDim = Color(0xFF450A0A);
  static const Color darkRoomRedText = Color(0xFF991B1B);
  static const Color darkRoomRedBright = Color(0xFFDC2626);

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static const LinearGradient sleepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFACC7FF), Color(0xFF468FFF)],
  );
}
