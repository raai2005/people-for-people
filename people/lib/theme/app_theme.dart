import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color primaryMedium = Color(0xFF16213E);
  static const Color primaryLight = Color(0xFF0F3460);
  static const Color accent = Color(0xFFE94560);
  static const Color accentLight = Color(0xFFFF6B6B);
  static const Color gold = Color(0xFFFFE66D);
  static const Color purple = Color(0xFF533483);

  // Role Colors
  static const Color ngoColor = Color(0xFF00BFA6);
  static const Color donorColor = Color(0xFFFF6B6B);
  static const Color volunteerColor = Color(0xFF7C4DFF);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryMedium, primaryLight, purple],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight, gold],
  );

  static LinearGradient ngoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ngoColor, ngoColor.withValues(alpha: 0.7)],
  );

  static LinearGradient donorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [donorColor, donorColor.withValues(alpha: 0.7)],
  );

  static LinearGradient volunteerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [volunteerColor, volunteerColor.withValues(alpha: 0.7)],
  );

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: white,
    letterSpacing: 1,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: white,
    letterSpacing: 0.5,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: white,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: white,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: white,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: grey,
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: accent),
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: white.withValues(alpha: 0.8)),
      hintStyle: TextStyle(color: white.withValues(alpha: 0.4)),
      filled: true,
      fillColor: white.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: white.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  // Button Styles
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    elevation: 8,
    shadowColor: accent.withValues(alpha: 0.5),
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    side: BorderSide(color: white.withValues(alpha: 0.5)),
  );

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: white.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: white.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(
        color: black.withValues(alpha: 0.2),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // Glass Effect
  static BoxDecoration glassDecoration = BoxDecoration(
    color: white.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: white.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(
        color: black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
