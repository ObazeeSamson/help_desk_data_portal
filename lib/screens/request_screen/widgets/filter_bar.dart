import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// Control bar providing date range filtering inputs, a reset button,
/// and a record count indicator.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.recordCount,
    required this.onFromSelected,
    required this.onToSelected,
    required this.onClear,
  });

  /// The active start date boundary for filtering tickets.
  final DateTime? fromDate;

  /// The active end date boundary for filtering tickets.
  final DateTime? toDate;

  /// The number of ticket records matching the active filters.
  final int recordCount;

  /// Callback fired when the user selects a start date from the date picker.
  final ValueChanged<DateTime?> onFromSelected;

  /// Callback fired when the user selects an end date from the date picker.
  final ValueChanged<DateTime?> onToSelected;

  /// Callback fired when the user clicks the clear button to reset dates.
  final VoidCallback onClear;

  /// Formats a [DateTime] into a standard `YYYY-MM-DD` display string.
  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    // True if at least one date boundary is active
    final hasFilter = fromDate != null || toDate != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // ── Section Label ─────────────────────────────────────────────────
          Text(
            'FILTER BY DATE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 14),

          // ── From Date Picker Trigger ──────────────────────────────────────
          _DatePickerButton(
            label: fromDate != null ? _formatDate(fromDate!) : 'FROM',
            currentDate: fromDate,
            onSelected: onFromSelected,
            isSet: fromDate != null,
          ),

          // Arrow divider between from and to
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '→',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),

          // ── To Date Picker Trigger ────────────────────────────────────────
          _DatePickerButton(
            label: toDate != null ? _formatDate(toDate!) : 'TO',
            currentDate: toDate,
            onSelected: onToSelected,
            isSet: toDate != null,
          ),

          // ── Clear Filter Button (Visible only when filters are active) ────
          if (hasFilter) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: 'Clear filter',
              child: InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),

          // ── Filtered Record Count Badge ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$recordCount ${recordCount == 1 ? 'Record' : 'Records'} Selected',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact outlined button that opens a styled Flutter [showDatePicker] modal.
class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.label,
    required this.currentDate,
    required this.onSelected,
    required this.isSet,
  });

  /// Display text on the button (e.g. "FROM" or "2026-10-18").
  final String label;

  /// The currently selected date value (if any).
  final DateTime? currentDate;

  /// Callback when a date is confirmed in the picker.
  final ValueChanged<DateTime?> onSelected;

  /// Whether a date has been selected (affects visual highlighting).
  final bool isSet;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        // Open the native Flutter date picker dialog
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDate: currentDate ?? DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) onSelected(picked);
      },
      icon: Icon(
        Icons.calendar_today_outlined,
        size: 11,
        color: isSet ? AppColors.primary : AppColors.textMuted,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSet ? AppColors.primary : AppColors.textMuted,
        side: BorderSide(
          color: isSet ? AppColors.primary : AppColors.border,
          width: isSet ? 1.5 : 1,
        ),
        backgroundColor: isSet ? AppColors.primarySurface : null,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        textStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: isSet ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
