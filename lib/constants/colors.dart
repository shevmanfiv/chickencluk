import 'package:flutter/material.dart';

/// Cluck Rush Design Language - Color Palette
/// 
/// These colors define the visual identity of the game.
/// Reference: documentation/designLanguageSystem.md

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================
  // PRIMARY COLORS (Brand Identity)
  // ============================================
  
  /// Penny Yellow - The Chicken
  /// Bright, energetic, main character color
  static const Color pennyYellow = Color(0xFFFFD54F);
  
  /// Farm Green - Ground/Hills
  /// Fresh, calming background element
  static const Color farmGreen = Color(0xFF8BC34A);
  
  /// Sky Blue - Background
  /// Openness, cheerful sky
  static const Color skyBlue = Color(0xFF4FC3F7);

  // ============================================
  // FUNCTIONAL COLORS (Gameplay Indicators)
  // ============================================
  
  /// Emerald Green - Success/Safe
  /// Used for: Full meter, "Next Level" buttons, positive feedback
  static const Color success = Color(0xFF66BB6A);
  
  /// Soft Red - Danger/Urgency
  /// Used for: Foxes, Obstacles, "Low Hunger" warning
  static const Color danger = Color(0xFFEF5350);
  
  /// Orange - Action/Interactive
  /// Used for: "Play" buttons to trigger impulse clicks
  static const Color action = Color(0xFFFF7043);

  // ============================================
  // NEUTRALS & UI
  // ============================================
  
  /// Wood Brown - UI Panels, Signs
  /// Rustic farm aesthetic for menus and dialogs
  static const Color woodBrown = Color(0xFF8D6E63);
  
  /// Off-White - Text backgrounds
  /// Easier on the eyes than pure white
  static const Color offWhite = Color(0xFFFFF9C4);
  
  /// Ink Black - Outlines & Text
  /// NEVER use pure #000000, it looks unnatural
  static const Color inkBlack = Color(0xFF2C2C2C);

  // ============================================
  // FULLNESS METER COLORS
  // ============================================
  
  /// High fullness (> 50%)
  static const Color meterHigh = success;
  
  /// Medium fullness (25% - 50%)
  static const Color meterMedium = Color(0xFFFFB74D); // Amber
  
  /// Low fullness (< 25%)
  static const Color meterLow = danger;

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Get the appropriate color for the fullness meter based on percentage
  static Color getMeterColor(double fullnessPercent) {
    if (fullnessPercent > 50) {
      return meterHigh;
    } else if (fullnessPercent > 25) {
      return meterMedium;
    } else {
      return meterLow;
    }
  }

  /// Get a darker shade of a color (for button shadows/depth)
  static Color darken(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Get a lighter shade of a color (for highlights)
  static Color lighten(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}

