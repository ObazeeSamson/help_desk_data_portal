import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/models/support_request.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/request_row.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// The core tabular presentation widget for support tickets.
///
/// Features:
/// - Horizontal scrolling for wide desktop viewports
/// - Full-width expansion via [LayoutBuilder] and [ConstrainedBox] (no trailing blank gaps)
/// - Modern enterprise styling with [AppColors]
/// - Fallback empty state when no records match active date filters
class RequestTable extends StatelessWidget {
  const RequestTable({
    super.key,
    required this.requests,
    required this.onStatusChanged,
    required this.onDelete,
  });

  /// The list of visible tickets for the current page.
  final List<SupportRequest> requests;

  /// Callback to change a ticket's status on the backend.
  final void Function(String id, String status) onStatusChanged;

  /// Callback to confirm and delete a ticket.
  final void Function(SupportRequest request) onDelete;

  /// Header column definitions displayed across the top of the table.
  static const _columns = [
    'ID',
    'STATUS',
    'DATE',
    'REQUESTING DEPT',
    'ROOM / EXT',
    'REQUESTING OFFICER',
    'DESIGNATION',
    'COMPLAINT DESCRIPTION',
    'DIAGNOSED BY',
    'ACTIONS',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal scrolling allows reviewing wide rows on smaller viewports
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    // Ensures the DataTable expands to fill the entire width of the card container
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 70,
                      columnSpacing: 24,
                      horizontalMargin: 16,
                      headingRowColor: WidgetStateProperty.all(AppColors.borderLight),
                      headingTextStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textSecondary,
                      ),
                      dividerThickness: 1,
                      dataTextStyle: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                      // Generate column header cells
                      columns: _columns
                          .map((col) => DataColumn(label: Text(col)))
                          .toList(),
                      // Generate data rows with alternating zebra striping
                      rows: List.generate(
                        requests.length,
                        (i) => RequestRow.build(
                          request: requests[i],
                          isEven: i.isEven,
                          onStatusChanged: onStatusChanged,
                          onDelete: () => onDelete(requests[i]),
                        ),
                      ),
                    ),
                  ),
                ),
                // Show empty placeholder banner if no tickets are available
                if (requests.isEmpty) _emptyState(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a friendly placeholder view when no records match filter criteria.
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 36,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'No requests match the current filters.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
