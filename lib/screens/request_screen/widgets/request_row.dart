import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/models/support_request.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/status_dropdown.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// Builder class for constructing a strongly typed [DataRow] corresponding
/// to a single [SupportRequest] record within the requests table.
///
/// Implements alternating zebra-striping colors and formats each individual column:
/// - ID, Status dropdown, Creation Date, Department, Room / Ext, Officer,
///   Designation, Truncated Description, Diagnosed By (Interactive), and Delete Action.
class RequestRow extends DataRow {
  // Private const constructor forwarding to super DataRow.
  const RequestRow._({required super.cells, super.color});

  /// Factory constructor assembling the cells for a given [request].
  ///
  /// Parameters:
  /// - [request]: The ticket data model.
  /// - [isEven]: Boolean indicating whether this row has an even index (used for zebra-striping).
  /// - [onStatusChanged]: Callback to mutate the ticket's resolution status.
  /// - [onAssignTechnician]: Callback to open the technician assignment dialog.
  /// - [onDelete]: Callback triggered when the delete trash-can button is clicked.
  factory RequestRow.build({
    required SupportRequest request,
    required bool isEven,
    required void Function(SupportRequest request, String status) onStatusChanged,
    required void Function(SupportRequest request) onAssignTechnician,
    required VoidCallback onDelete,
  }) {
    // Format timestamp as YYYY-MM-DD
    final dateStr =
        '${request.createdAt.year}-'
        '${request.createdAt.month.toString().padLeft(2, '0')}-'
        '${request.createdAt.day.toString().padLeft(2, '0')}';

    return RequestRow._(
      // Alternating row background for enhanced tabular readability
      color: isEven
          ? WidgetStateProperty.all(AppColors.surface)
          : WidgetStateProperty.all(AppColors.borderLight),
      cells: [
        // ── 1. Ticket ID ────────────────────────────────────────────────────
        DataCell(
          Text(
            '#${request.ticketId}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // ── 2. Interactive Status Dropdown ──────────────────────────────────
        DataCell(
          StatusDropdown(
            request: request,
            onStatusChanged: onStatusChanged,
          ),
        ),

        // ── 3. Submission Date ──────────────────────────────────────────────
        DataCell(
          Text(
            dateStr,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // ── 4. Requesting Department ────────────────────────────────────────
        DataCell(
          Text(
            request.department,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
          ),
        ),

        // ── 5. Room / Extension ─────────────────────────────────────────────
        DataCell(
          Text(
            request.location,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // ── 6. Requesting Officer ───────────────────────────────────────────
        DataCell(
          Text(
            request.officer,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // ── 7. Officer Designation / Title ──────────────────────────────────
        DataCell(
          Text(
            request.designation,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // ── 8. Complaint Description (Clamped with Ellipsis) ─────────────────
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // ── 9. Diagnosed By (Interactive Technician Assignment) ─────────────
        DataCell(
          Builder(
            builder: (context) {
              final raw = request.diagnosedBy.trim().toLowerCase();
              final isAssigned =
                  raw.isNotEmpty && raw != 'unassigned' && raw != 'null';

              if (!isAssigned) {
                return Tooltip(
                  message: 'Assign a technician',
                  child: InkWell(
                    onTap: () => onAssignTechnician(request),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Assign',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Tooltip(
                message: 'Click to reassign technician',
                child: InkWell(
                  onTap: () => onAssignTechnician(request),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            request.diagnosedBy,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── 10. Delete Action Button ────────────────────────────────────────
        DataCell(
          Tooltip(
            message: 'Delete request',
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
