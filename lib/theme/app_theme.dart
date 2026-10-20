import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic color design tokens for the ICT Help Desk Data Portal.
///
/// Designed around an organizational green primary palette with accessible
/// contrast ratios and clean, modern enterprise aesthetics.
class AppColors {
  // ── Brand Greens ───────────────────────────────────────────────────────────
  /// Primary Nigerian Ports Authority / enterprise brand green.
  static const primary = Color(0xFF00843D);

  /// Darker shade of primary for hover states and active buttons.
  static const primaryDark = Color(0xFF006B31);

  /// Lighter accent green for badges, highlights, and borders.
  static const primaryLight = Color(0xFF00A84D);

  /// Soft tinted background for primary-colored chips and highlights.
  static const primarySurface = Color(0xFFE8F5EE);

  // ── Neutral & Canvas Colors ───────────────────────────────────────────────
  /// Main scaffold background color (cool off-white/grey).
  static const background = Color(0xFFF4F6F9);

  /// White surface color for cards, modals, table rows, and headers.
  static const surface = Color(0xFFFFFFFF);

  /// Standard border color for containers, inputs, and dividers.
  static const border = Color(0xFFE3E8EE);

  /// Subtler light border or zebra-striping background for tables.
  static const borderLight = Color(0xFFF0F3F7);

  // ── Typography & Text Colors ──────────────────────────────────────────────
  /// High-emphasis primary text color (near-black with deep slate undertones).
  static const textPrimary = Color(0xFF101C30);

  /// Medium-emphasis secondary text color for captions, labels, and table cells.
  static const textSecondary = Color(0xFF52637A);

  /// Low-emphasis muted text color for placeholders, empty states, and subtle hints.
  static const textMuted = Color(0xFF8A99AE);

  /// Text color placed on top of primary colored buttons and headers.
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Ticket Status Indicators ──────────────────────────────────────────────
  /// Forest green text for 'Resolved' status badges.
  static const resolvedText = Color(0xFF0D9B70);

  /// Soft mint background for 'Resolved' status badges.
  static const resolvedBg = Color(0xFFE5FBF3);

  /// Royal blue text for 'In Progress' status badges.
  static const inProgressText = Color(0xFF2877E8);

  /// Soft light blue background for 'In Progress' status badges.
  static const inProgressBg = Color(0xFFEAF2FF);

  /// Amber text for 'Pending' status badges.
  static const pendingText = Color(0xFFB36A00);

  /// Warm amber-tinted background for 'Pending' status badges.
  static const pendingBg = Color(0xFFFFF4DF);

  // ── Danger & Destructive Actions ──────────────────────────────────────────
  /// Vivid red for delete buttons, error alerts, and destructive actions.
  static const danger = Color(0xFFD94040);

  /// Light pink background for destructive button hover/fill states.
  static const dangerLight = Color(0xFFFFF0F0);
}

/// Global theme definition for the application.
///
/// Configures Flutter's [ThemeData] with custom typography (Google Fonts Inter),
/// button styles, input decorations, and dialog styling.
class AppTheme {
  /// Builds the light theme configuration for the application.
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: false);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      // Set Inter typography across all text styles
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
      // Flat, clean enterprise AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      // Elevated button styling (primary actions like Login, Export CSV)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
        ),
      ),
      // Outlined button styling (secondary actions like Clear, Date Filter, Cancel)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.border),
          textStyle: GoogleFonts.inter(fontSize: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      // Text button styling (inline actions like Dialog actions)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Text input field styling
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      // Subtle dividers across the UI
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      // Confirmation dialog styling
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
