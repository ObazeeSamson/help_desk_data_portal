import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.totalRecords,
    required this.pageSize,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final int totalRecords;
  final int pageSize;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final start = totalRecords == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final end = (currentPage * pageSize).clamp(0, totalRecords);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            totalRecords == 0
                ? 'No entries'
                : 'Showing $start–$end of $totalRecords entries',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPrevious,
            tooltip: 'Previous page',
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '$currentPage / $pageCount',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: enabled ? AppColors.surface : AppColors.borderLight,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            icon,
            size: 16,
            color: enabled ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
