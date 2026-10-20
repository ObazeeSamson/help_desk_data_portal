import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/models/support_request.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// Visual indicator chip displaying the resolution state of a support ticket.
///
/// Uses distinct background, text, and bullet-dot colors for each [RequestStatus]:
/// - Resolved: Subtle green chip with forest-green dot
/// - In Progress: Subtle blue chip with royal-blue dot
/// - Pending: Subtle amber chip with amber dot
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  /// The ticket resolution status to represent visually.
  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    // Dart 3 pattern-matching switch expression to resolve typography & color tokens
    final (label, textColor, bgColor, dotColor) = switch (status) {
      RequestStatus.resolved => (
          'Resolved',
          AppColors.resolvedText,
          AppColors.resolvedBg,
          AppColors.resolvedText,
        ),
      RequestStatus.inProgress => (
          'In Progress',
          AppColors.inProgressText,
          AppColors.inProgressBg,
          AppColors.inProgressText,
        ),
      RequestStatus.pending => (
          'Pending',
          AppColors.pendingText,
          AppColors.pendingBg,
          AppColors.pendingText,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small colored status indicator dot
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          // Human-readable status label
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
