import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_desk_data_portal/models/support_request.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/assign_technician_dialog.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/filter_bar.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/pagination_bar.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/request_header.dart';
import 'package:help_desk_data_portal/screens/request_screen/widgets/request_table.dart';
import 'package:help_desk_data_portal/services/help_desk_service.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// Primary coordinator screen for viewing, filtering, updating, and managing
/// ICT Help Desk support tickets.
///
/// Manages application state for:
/// - Asynchronous request fetching
/// - Background auto-polling for new requests
/// - Status modifications
/// - Technician assignment
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

  /// How often the background poller silently checks for new requests.
  static const Duration _pollInterval = Duration(seconds: 5);

  /// Master list of all support requests retrieved from the database.
  List<SupportRequest> _requests = [];

  /// Tracks whether data is actively loading from the API (initial load only).
  bool _isLoading = true;

  /// Holds network or server error descriptions if fetching fails.
  String? _errorMessage;

  /// Active 1-indexed pagination page.
  int _currentPage = 1;

  /// Start date constraint for filtering tickets by [SupportRequest.createdAt].
  DateTime? _fromDate;

  /// End date constraint for filtering tickets by [SupportRequest.createdAt].
  DateTime? _toDate;

  /// The highest ticket ID seen so far, used to detect newly submitted requests.
  /// Initialised to -1 so any real ticket ID will trigger the first comparison correctly.
  int _lastKnownMaxId = -1;

  /// Background timer that silently polls the backend for new requests.
  Timer? _pollTimer;

  /// Count of new tickets received since last manual refresh / acknowledgement.
  int _newRequestCount = 0;

  @override
  void initState() {
    super.initState();
    // Fetch tickets immediately upon entering the dashboard
    _fetchRequests();
    // Start the background polling timer
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollForNewRequests());
  }

  @override
  void dispose() {
    // Always cancel the timer when leaving the screen to avoid memory leaks
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── Network & CRUD Operations ─────────────────────────────────────────────

  /// Fetches support tickets from the backend via [HelpDeskService].
  ///
  /// On first load, also seeds [_lastKnownMaxId] so the poller has a baseline.
  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _newRequestCount = 0;
    });

    try {
      final data = await HelpDeskService.fetchRequests();
      if (!mounted) return;
      setState(() {
        _requests = data;
        _isLoading = false;
        // Seed the baseline max ID after initial load
        if (data.isNotEmpty) {
          _lastKnownMaxId = data
              .map((r) => int.tryParse(r.ticketId) ?? 0)
              .reduce((a, b) => a > b ? a : b);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connection error. Check that backend is accessible.';
        _isLoading = false;
      });
    }
  }

  /// Silent background poll: checks for new tickets without showing a loading spinner.
  ///
  /// Compares the highest ticket ID in the latest fetch against [_lastKnownMaxId].
  /// If new tickets are found, it updates the list and shows a notification banner.
  Future<void> _pollForNewRequests() async {
    if (!mounted) return;
    try {
      final data = await HelpDeskService.fetchRequests();
      if (!mounted) return;

      if (data.isEmpty) return;

      final latestMaxId = data
          .map((r) => int.tryParse(r.ticketId) ?? 0)
          .reduce((a, b) => a > b ? a : b);

      // New tickets have arrived since our last known state
      if (_lastKnownMaxId >= 0 && latestMaxId > _lastKnownMaxId) {
        final newCount = latestMaxId - _lastKnownMaxId;
        setState(() {
          _requests = data;
          _lastKnownMaxId = latestMaxId;
          _newRequestCount = newCount;
          _currentPage = 1; // Jump to first page to show new tickets
        });
        _showNewRequestBanner(newCount);
      }
    } catch (_) {
      // Silently ignore poll errors — user still sees existing data
    }
  }

  /// Displays a prominent notification banner when new requests arrive.
  void _showNewRequestBanner(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.inProgressText,
        content: Row(
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count new request${count > 1 ? 's' : ''} received!',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles a status change initiated from the status dropdown.
  ///
  /// Changes status directly without requiring technician input.
  Future<void> _handleStatusChange(
    SupportRequest request,
    String newStatus,
  ) async {
    await _updateStatus(request.ticketId, newStatus);
  }

  /// Opens the technician assignment dialog directly to assign or reassign a technician.
  Future<void> _handleAssignTechnician(SupportRequest request) async {
    final technician = await AssignTechnicianDialog.show(
      context,
      request: request,
    );

    if (technician == null || technician.trim().isEmpty) return;

    try {
      await HelpDeskService.assignTechnician(
        request.ticketId,
        technician.trim(),
        status: request.status.backendValue,
      );
      if (!mounted) return;
      _showSnack('Technician assigned successfully.');
      _fetchRequests();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to assign technician: $e', isError: true);
    }
  }

  /// Sends a status change request to the API, shows a snackbar, and refreshes the list.
  Future<void> _updateStatus(
    String id,
    String status, {
    String? diagnosedBy,
  }) async {
    try {
      await HelpDeskService.updateStatus(id, status, diagnosedBy: diagnosedBy);
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
        final start = DateTime(
          _fromDate!.year,
          _fromDate!.month,
          _fromDate!.day,
        );
        if (r.createdAt.isBefore(start)) return false;
      }
      if (_toDate != null) {
        final end = DateTime(
          _toDate!.year,
          _toDate!.month,
          _toDate!.day,
          23,
          59,
          59,
        );
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
  int get _pageCount =>
      _filtered.isEmpty ? 1 : (_filtered.length / _pageSize).ceil();

  /// Updates from-date filter and resets pagination back to page 1.
  void _setFromDate(DateTime? d) => setState(() {
    _fromDate = d;
    _currentPage = 1;
  });

  /// Updates to-date filter and resets pagination back to page 1.
  void _setToDate(DateTime? d) => setState(() {
    _toDate = d;
    _currentPage = 1;
  });

  /// Clears active date filters and returns to page 1.
  void _clearFilters() => setState(() {
    _fromDate = null;
    _toDate = null;
    _currentPage = 1;
  });

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

  /// Builds the page title header row with a Refresh button and live status indicator.
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
              const SizedBox(height: 4),
              // Live polling indicator
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.resolvedText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Live',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (_newRequestCount > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inProgressBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.inProgressText.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: Text(
                        '$_newRequestCount new',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inProgressText,
                        ),
                      ),
                    ),
                  ],
                ],
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
              const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
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
          onStatusChanged: _handleStatusChange,
          onAssignTechnician: _handleAssignTechnician,
          onDelete: _confirmDelete,
        ),
        // Pagination navigation footer
        PaginationBar(
          currentPage: _currentPage,
          pageCount: _pageCount,
          totalRecords: _filtered.length,
          pageSize: _pageSize,
          onPrevious: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
          onNext: _currentPage < _pageCount
              ? () => setState(() => _currentPage++)
              : null,
        ),
      ],
    );
  }
}
