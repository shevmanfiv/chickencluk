import 'package:flutter/material.dart';
import 'colors.dart';

/// Cluck Rush Design Language - Typography
/// 
/// Font families and text styles for consistent UI.
/// Reference: documentation/designLanguageSystem.md

class AppTypography {
  AppTypography._(); // Private constructor to prevent instantiation

  // ============================================
  // FONT FAMILIES
  // ============================================
  
  /// Lilita One - Headline Font
  /// Usage: Logo, Level Titles, "Game Over", Button Text
  /// Vibe: Chunky, rounded, fun
  static const String headlineFont = 'LilitaOne';
  
  /// Rubik - Body Font
  /// Usage: Tutorial text, Settings menu, Story descriptions
  /// Vibe: Highly readable, rounded edges
  static const String bodyFont = 'Rubik';

  // ============================================
  // HEADLINE STYLES (Lilita One)
  // ============================================
  
  /// Game title / Logo
  static const TextStyle logo = TextStyle(
    fontFamily: headlineFont,
    fontSize: 48,
    color: AppColors.inkBlack,
    letterSpacing: 1.2,
  );
  
  /// Level titles, Screen headers
  static const TextStyle headline1 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 36,
    color: AppColors.inkBlack,
  );
  
  /// Section headers, Dialog titles
  static const TextStyle headline2 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 28,
    color: AppColors.inkBlack,
  );
  
  /// Smaller headlines, Category labels
  static const TextStyle headline3 = TextStyle(
    fontFamily: headlineFont,
    fontSize: 22,
    color: AppColors.inkBlack,
  );

  // ============================================
  // BUTTON TEXT STYLES (Lilita One)
  // ============================================
  
  /// Large primary buttons (Play, Start)
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: headlineFont,
    fontSize: 28,
    color: AppColors.offWhite,
    letterSpacing: 1.0,
  );
  
  /// Standard buttons
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: headlineFont,
    fontSize: 22,
    color: AppColors.offWhite,
  );
  
  /// Small buttons, secondary actions
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: headlineFont,
    fontSize: 18,
    color: AppColors.offWhite,
  );

  // ============================================
  // BODY TEXT STYLES (Rubik)
  // ============================================
  
  /// Main body text
  /// Weight: Bold (700) for readability on small screens
  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
  );
  
  /// Smaller body text
  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
  );
  
  /// Large body text for emphasis
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
  );

  // ============================================
  // HUD / IN-GAME STYLES
  // ============================================
  
  /// Distance indicator, Score display
  static const TextStyle hudText = TextStyle(
    fontFamily: headlineFont,
    fontSize: 20,
    color: AppColors.offWhite,
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 2,
        color: AppColors.inkBlack,
      ),
    ],
  );
  
  /// Timer, Fullness percentage
  static const TextStyle hudNumber = TextStyle(
    fontFamily: headlineFont,
    fontSize: 24,
    color: AppColors.offWhite,
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 2,
        color: AppColors.inkBlack,
      ),
    ],
  );

  // ============================================
  // SPECIAL STYLES
  // ============================================
  
  /// Game Over text
  static const TextStyle gameOver = TextStyle(
    fontFamily: headlineFont,
    fontSize: 42,
    color: AppColors.danger,
    shadows: [
      Shadow(
        offset: Offset(3, 3),
        blurRadius: 4,
        color: AppColors.inkBlack,
      ),
    ],
  );
  
  /// Victory text
  static const TextStyle victory = TextStyle(
    fontFamily: headlineFont,
    fontSize: 42,
    color: AppColors.success,
    shadows: [
      Shadow(
        offset: Offset(3, 3),
        blurRadius: 4,
        color: AppColors.inkBlack,
      ),
    ],
  );
  
  /// Tutorial/hint text
  static const TextStyle tutorial = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.woodBrown,
  );
}

