import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// Top persistent navigation bar displayed across the request dashboard.
///
/// Features:
/// - Organizational logo and brand badge
/// - Staff access security indicator
/// - 'Lock Portal' action button to pop back to the password screen
class RequestHeader extends StatelessWidget {
  const RequestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // ── Brand Logo Icon ───────────────────────────────────────────────
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          // ── Portal Title & Tag ────────────────────────────────────────────
          Text(
            'ICT Help Desk',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'DATA PORTAL',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          // ── Security Level Notice ─────────────────────────────────────────
          Text(
            'AUTHORIZED STAFF ONLY',
            style: GoogleFonts.inter(
              fontSize: 9,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 20),
          // ── Lock / Logout Button ──────────────────────────────────────────
          OutlinedButton.icon(
            // Popping navigates back to the PasswordScreen, locking the session
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.lock_outline, size: 13),
            label: const Text('Lock Portal'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
