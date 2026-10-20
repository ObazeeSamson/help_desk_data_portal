import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/models/support_request.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/filter_bar.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/pagination_bar.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/request_header.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/request_table.dart';
import 'package:help_desk_data_portal/services/help_desk_service.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// Primary coordinator screen for viewing, filtering, updating, and exporting
/// ICT Help Desk support tickets.
///
/// Manages application state for:
/// - Asynchronous request fetching
/// - Status modifications
/// - Ticket deletions
/// - Date range filtering
/// - Pagination slicing
class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  /// Number of records displayed per table page.
  static const int _pageSize = 8;

  /// Master list of all support requests retrieved from the database.
  List<SupportRequest> _requests = [];

  /// Tracks whether data is actively loading from the API.
  bool _isLoading = true;

  /// Holds network or server error descriptions if fetching fails.
  String? _errorMessage;

  /// Active 1-indexed pagination page.
  int _currentPage = 1;

  /// Start date constraint for filtering tickets by [SupportRequest.createdAt].
  DateTime? _fromDate;

  /// End date constraint for filtering tickets by [SupportRequest.createdAt].
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    // Fetch tickets immediately upon entering the dashboard
    _fetchRequests();
  }

  // ── Network & CRUD Operations ─────────────────────────────────────────────

  /// Fetches support tickets from the backend via [HelpDeskService].
  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await HelpDeskService.fetchRequests();
      if (!mounted) return;
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connection error. Check that backend is accessible.';
        _isLoading = false;
      });
    }
  }

  /// Sends a status change request to the API, shows a snackbar, and refreshes the list.
  Future<void> _updateStatus(String id, String status) async {
    try {
      await HelpDeskService.updateStatus(id, status);
      if (!mounted) return;
      _showSnack('Status updated successfully.');
      _fetchRequests();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to update status.', isError: true);
    }
  }

  /// Displays a confirmation dialog before executing a permanent ticket deletion.
  Future<void> _confirmDelete(SupportRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request?'),
        content: Text(
          'Are you sure you want to delete request #${request.ticketId}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If user clicked Delete, invoke service to delete from DB
    if (confirmed == true) {
      try {
        await HelpDeskService.deleteRequest(request.ticketId);
        if (!mounted) return;
        _showSnack('Request deleted.');
        _fetchRequests();
      } catch (e) {
        if (!mounted) return;
        _showSnack('Failed to delete request.', isError: true);
      }
    }
  }

  /// Displays floating feedback snackbars.
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  // ── Filtering & Pagination Logic ──────────────────────────────────────────

  /// Returns the subset of [_requests] matching the active [_fromDate] and [_toDate] constraints.
  List<SupportRequest> get _filtered {
    return _requests.where((r) {
      if (_fromDate != null) {
        final start = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
        if (r.createdAt.isBefore(start)) return false;
      }
      if (_toDate != null) {
        final end = DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
        if (r.createdAt.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  /// Slices [_filtered] to return only the items belonging to the current page.
  List<SupportRequest> get _visible {
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _filtered.length) return const [];
    final end = (start + _pageSize).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  /// Calculates total page count based on filtered item count and [_pageSize].
  int get _pageCount => _filtered.isEmpty ? 1 : (_filtered.length / _pageSize).ceil();

  /// Updates from-date filter and resets pagination back to page 1.
  void _setFromDate(DateTime? d) => setState(() { _fromDate = d; _currentPage = 1; });

  /// Updates to-date filter and resets pagination back to page 1.
  void _setToDate(DateTime? d) => setState(() { _toDate = d; _currentPage = 1; });

  /// Clears active date filters and returns to page 1.
  void _clearFilters() => setState(() { _fromDate = null; _toDate = null; _currentPage = 1; });

  // ── UI Construction ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top persistent navigation bar
            const RequestHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pageTitle(),
                    const SizedBox(height: 20),
                    // Date range picker and counter toolbar
                    FilterBar(
                      fromDate: _fromDate,
                      toDate: _toDate,
                      recordCount: _filtered.length,
                      onFromSelected: _setFromDate,
                      onToSelected: _setToDate,
                      onClear: _clearFilters,
                    ),
                    const SizedBox(height: 16),
                    // Main content area: loading indicator, error state, or data table
                    _body(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the page title header row along with Refresh and Export buttons.
  Widget _pageTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submitted Requests & Logs',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Internal registry of ICT support submissions and resolution status.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Refresh button pulls latest entries from MySQL
        OutlinedButton.icon(
          onPressed: _fetchRequests,
          icon: const Icon(Icons.refresh_rounded, size: 15),
          label: const Text('Refresh'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(width: 8),
        // Export button downloads filtered results as a .csv file
        ElevatedButton.icon(
          onPressed: () => HelpDeskService.downloadCsv(from: _fromDate, to: _toDate),
          icon: const Icon(Icons.download_rounded, size: 15),
          label: const Text('Export CSV'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  /// Builds the dynamic body based on network status (loading, error, or data table).
  Widget _body() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 14),
              Text(
                'Loading records…',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchRequests,
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Main support request data table
        RequestTable(
          requests: _visible,
          onStatusChanged: _updateStatus,
          onDelete: _confirmDelete,
        ),
        // Pagination navigation footer
        PaginationBar(
          currentPage: _currentPage,
          pageCount: _pageCount,
          totalRecords: _filtered.length,
          pageSize: _pageSize,
          onPrevious: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          onNext: _currentPage < _pageCount ? () => setState(() => _currentPage++) : null,
        ),
      ],
    );
  }
}
