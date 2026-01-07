import 'package:flutter/material.dart';

class AppTheme {
  // Professional Color Palette
  static const Color primaryDark = Color(0xFF1E293B);  // Slate 800
  static const Color primaryMedium = Color(0xFF334155); // Slate 700
  static const Color primaryLight = Color(0xFF475569);  // Slate 600
  static const Color accent = Color(0xFFE11D48);        // Rose 600 - vibrant but professional
  static const Color accentLight = Color(0xFFFB7185);   // Rose 400
  static const Color gold = Color(0xFFF59E0B);          // Amber 500
  static const Color purple = Color(0xFF7C3AED);        // Violet 600

  // Role Colors - Refined and cohesive
  static const Color ngoColor = Color(0xFF0D9488);      // Teal 600
  static const Color donorColor = Color(0xFFDC2626);    // Red 600
  static const Color volunteerColor = Color(0xFF7C3AED); // Violet 600

  // Neutral Colors - Professional greys
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);      // Very light grey
  static const Color black = Color(0xFF0F172A);         // Slate 900
  static const Color grey = Color(0xFF64748B);          // Slate 500
  static const Color lightGrey = Color(0xFFF1F5F9);     // Slate 100
  static const Color darkGrey = Color(0xFF475569);      // Slate 600
  static const Color borderGrey = Color(0xFFE2E8F0);    // Slate 200

  // Status Colors - Refined
  static const Color success = Color(0xFF059669);       // Emerald 600
  static const Color warning = Color(0xFFD97706);       // Amber 600
  static const Color error = Color(0xFFDC2626);         // Red 600
  static const Color info = Color(0xFF0284C7);          // Sky 600

  // Solid colors - No gradients for clean white theme
  // Role colors are used as solid backgrounds for icons and accents
  static const Color ngoSolidColor = ngoColor;
  static const Color donorSolidColor = donorColor;
  static const Color volunteerSolidColor = volunteerColor;
  static const Color accentSolidColor = accent;

  // Text Styles - Professional Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: primaryDark,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: primaryDark,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: primaryDark,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: primaryDark,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: darkGrey,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: grey,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: grey,
    letterSpacing: 0.1,
  );

  // Input Decoration - Clean and Professional
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: grey, size: 20),
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(color: grey, fontSize: 14, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: grey.withValues(alpha: 0.7), fontSize: 14),
      filled: true,
      fillColor: lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryDark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Button Styles - Professional and refined
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryDark,
    foregroundColor: white,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: primaryDark,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: const BorderSide(color: borderGrey, width: 1.5),
  );

  static ButtonStyle accentButton = ElevatedButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: white,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  // Card Decoration - Clean with subtle shadow
  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderGrey),
    boxShadow: [
      BoxShadow(
        color: black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Clean Card Decoration - Elevated look
  static BoxDecoration cleanCardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderGrey),
    boxShadow: [
      BoxShadow(
        color: black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Elevated Card - For important elements
  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
