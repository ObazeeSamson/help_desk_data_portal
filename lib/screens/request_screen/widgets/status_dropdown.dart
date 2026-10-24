import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/models/support_request.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/status_badge.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// An interactive dropdown widget embedded inside table rows allowing staff
/// to directly mutate a ticket's status.
///
/// Wraps a [StatusBadge] with a popup menu containing:
/// - Pending
/// - In Progress (triggers technician assignment prompt)
/// - Resolved
class StatusDropdown extends StatelessWidget {
  const StatusDropdown({
    super.key,
    required this.request,
    required this.onStatusChanged,
  });

  /// The ticket whose status is being represented and modified.
  final SupportRequest request;

  /// Callback fired when an option is selected from the popup menu, passing
  /// the ticket model and target backend status string.
  final void Function(SupportRequest request, String status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Change status',
      // Trigger callback with selected backend status value
      onSelected: (newStatus) => onStatusChanged(request, newStatus),
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => [
        _menuItem('pending', 'Pending', AppColors.pendingText),
        _menuItem('in_progress', 'In Progress', AppColors.inProgressText),
        _menuItem('resolved', 'Resolved', AppColors.resolvedText),
      ],
      // Clickable trigger displaying the current status badge and a dropdown arrow
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(request.status),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_drop_down_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  /// Helper generating a styled [PopupMenuItem] for a given status option.
  PopupMenuItem<String> _menuItem(String value, String label, Color color) {
    return PopupMenuItem(
      value: value,
      height: 38,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
