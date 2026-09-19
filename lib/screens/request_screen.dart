import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum RequestStatus { resolved, inProgress, pending }

class SupportRequest {
  const SupportRequest({
    required this.ticketId,
    required this.status,
    required this.department,
    required this.location,
    required this.officer,
    required this.designation,
    required this.description,
    required this.diagnosedBy,
    required this.createdAt,
  });

  final String ticketId;
  final RequestStatus status;
  final String department;
  final String location;
  final String officer;
  final String designation;
  final String description;
  final String diagnosedBy;
  final DateTime createdAt;

  // Updated to parse your exact MySQL column names
  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    RequestStatus parseStatus(String? val) {
      final s = (val ?? '').toLowerCase();

      if (s.contains('progress')) {
        return RequestStatus.inProgress;
      }

      if (s.contains('resolved')) {
        return RequestStatus.resolved;
      }

      return RequestStatus.pending;
    }

    // Handles either created_at or `create` if truncated in MySQL
    final rawDate = json['created_at'] ?? json['create'];

    return SupportRequest(
      ticketId: json['id']?.toString() ?? '',
      status: parseStatus(json['status']?.toString()),
      department: json['requesting_department']?.toString() ?? '',
      location: json['room_extension']?.toString() ?? '',
      officer: json['requesting_officer']?.toString() ?? '',
      designation: json['requester_designation']?.toString() ?? '',
      description: json['complaint_description']?.toString() ?? '',
      diagnosedBy: json['diagnosed_by']?.toString() ?? 'Unassigned',
      createdAt: rawDate != null
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  int currentPage = 1;
  static const int pageSize = 8;

  List<SupportRequest> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  void downloadCsv() {
    final params = <String, String>{};

    if (_fromDate != null) {
      params['from'] =
          '${_fromDate!.year}-'
          '${_fromDate!.month.toString().padLeft(2, '0')}-'
          '${_fromDate!.day.toString().padLeft(2, '0')}';
    }

    if (_toDate != null) {
      params['to'] =
          '${_toDate!.year}-'
          '${_toDate!.month.toString().padLeft(2, '0')}-'
          '${_toDate!.day.toString().padLeft(2, '0')}';
    }

    final uri = Uri.http(
      'localhost',
      '/help_desk_request/export_requests.php',
      params,
    );

    html.window.location.href = uri.toString();
  }

  Future<void> deleteRequest(String id) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/help_desk_request/delete_request.php'),
        body: {'id': id},
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.body.trim() == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request deleted successfully.')),
        );

        fetchRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete request.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Connection error.')));
    }
  }

  Future<void> _confirmDelete(SupportRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Request?'),
          content: Text(
            'Are you sure you want to delete request #${request.ticketId}?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await deleteRequest(request.ticketId);
    }
  }

  Future<void> fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost/help_desk_request/get_requests.php'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == 'success') {
          final List rawList = decoded['data'] ?? [];
          setState(() {
            _requests = rawList
                .map(
                  (item) =>
                      SupportRequest.fromJson(item as Map<String, dynamic>),
                )
                .toList();
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _errorMessage = 'Failed to load records from server.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connection error. Check Apache and MySQL status.';
        _isLoading = false;
      });
    }
  }

  List<SupportRequest> get filteredRequests {
    return _requests.where((req) {
      if (_fromDate != null) {
        final start = DateTime(
          _fromDate!.year,
          _fromDate!.month,
          _fromDate!.day,
        );
        if (req.createdAt.isBefore(start)) return false;
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
        if (req.createdAt.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  List<SupportRequest> get visibleRequests {
    final start = (currentPage - 1) * pageSize;
    if (start >= filteredRequests.length) return const [];
    final end = (start + pageSize).clamp(0, filteredRequests.length);
    return filteredRequests.sublist(start, end);
  }

  int get pageCount => filteredRequests.isEmpty
      ? 1
      : (filteredRequests.length / pageSize).ceil();

  void _setFromDate(DateTime? date) {
    setState(() {
      _fromDate = date;
      currentPage = 1;
    });
  }

  void _setToDate(DateTime? date) {
    setState(() {
      _toDate = date;
      currentPage = 1;
    });
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _RequestHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pageIntro(),
                    const SizedBox(height: 20),
                    _filters(),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: fetchRequests,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      _table(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageIntro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submitted Requests & Logs',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff101c30),
                ),
              ),
              SizedBox(height: 5),
              // Text(
              //   'Internal registry of ICT support submissions, technician diagnostics, and resolution status structured for analysis.',
              //   style: TextStyle(
              //     fontSize: 14,
              //     height: 1.5,
              //     color: Color(0xff617089),
              //   ),
              // ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: downloadCsv,
          icon: const Icon(Icons.download, size: 18),
          label: const Text(
            'Export Data',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            // backgroundColor: const Color.fromARGB(255, 3, 50, 124),
            // foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: fetchRequests,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text(
            'Refresh Data',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            // backgroundColor: const Color(0xff09162b),
            // foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffdfe5ec)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          _datePicker(
            label: _fromDate != null
                ? '${_fromDate!.year}-${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}'
                : 'FROM',
            currentDate: _fromDate,
            onSelected: _setFromDate,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('—', style: TextStyle(color: Color(0xff9aa6b7))),
          ),
          _datePicker(
            label: _toDate != null
                ? '${_toDate!.year}-${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}'
                : 'TO',
            currentDate: _toDate,
            onSelected: _setToDate,
          ),
          if (_fromDate != null || _toDate != null) ...[
            const SizedBox(width: 10),
            IconButton(
              tooltip: 'Clear filter',
              icon: const Icon(Icons.clear, size: 16, color: Colors.redAccent),
              onPressed: _clearFilters,
            ),
          ],
          const SizedBox(width: 15),
          Text(
            '${filteredRequests.length} Records Selected',
            style: const TextStyle(fontSize: 12, color: Color(0xff53647a)),
          ),
        ],
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? currentDate,
    required Function(DateTime?) onSelected,
  }) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDate: currentDate ?? DateTime.now(),
        );
        if (picked != null) {
          onSelected(picked);
        }
      },
      icon: const Icon(Icons.calendar_today_outlined, size: 12),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xff617089)),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 105, 137, 97),
        side: const BorderSide(color: Color(0xffdfe5ec)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
    );
  }

  Widget _table() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffdfe5ec)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 35,
              dataRowMinHeight: 54,
              dataRowMaxHeight: 68,
              columnSpacing: 28,
              headingTextStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
                color: Color(0xff64738a),
              ),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('DATE')),
                DataColumn(label: Text('REQUESTING DEPT')),
                DataColumn(label: Text('ROOM / EXT')),
                DataColumn(label: Text('REQUESTING OFFICER')),
                DataColumn(label: Text('REQUESTER DESIGNATION')),
                DataColumn(label: Text('COMPLAINT DESCRIPTION')),
                DataColumn(label: Text('DIAGNOSED BY')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: visibleRequests.map(_requestRow).toList(),
            ),
          ),
          if (visibleRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Text(
                'No requests match the current filters.',
                style: TextStyle(fontSize: 12, color: Color(0xff7a8799)),
              ),
            ),
          _pagination(),
        ],
      ),
    );
  }

  DataRow _requestRow(SupportRequest request) {
    final dateStr =
        '${request.createdAt.year}-${request.createdAt.month.toString().padLeft(2, '0')}-${request.createdAt.day.toString().padLeft(2, '0')}';

    return DataRow(
      cells: [
        DataCell(
          Text(
            request.ticketId,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        DataCell(_statusDropdown(request)),
        DataCell(
          Text(
            dateStr,
            style: const TextStyle(fontSize: 13, color: Color(0xff697a91)),
          ),
        ),
        DataCell(
          Text(request.department, style: const TextStyle(fontSize: 13)),
        ),
        DataCell(
          Text(
            request.location,
            style: const TextStyle(fontSize: 13, color: Color(0xff697a91)),
          ),
        ),
        DataCell(
          Text(
            request.officer,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(request.designation, style: const TextStyle(fontSize: 10)),
        ),
        DataCell(
          SizedBox(
            width: 190,
            child: Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ),
        DataCell(
          Text(
            request.diagnosedBy,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          IconButton(
            tooltip: 'Delete request',
            icon: const Icon(
              Icons.delete_outline,
              size: 17,
              color: Colors.redAccent,
            ),
            onPressed: () => _confirmDelete(request),
          ),
        ),
      ],
    );
  }

  // Update Status
  Future<void> updateStatus(String id, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/help_desk_request/update_status.php'),
        body: {'id': id, 'status': status},
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.body.trim() == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully.')),
        );

        fetchRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Connection error.')));
    }
  }

  Widget _statusDropdown(SupportRequest request) {
    return PopupMenuButton<String>(
      tooltip: 'Change status',
      onSelected: (newStatus) {
        updateStatus(request.ticketId, newStatus);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'pending', child: Text('Pending')),
        PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
        PopupMenuItem(value: 'resolved', child: Text('Resolved')),
      ],
      child: _status(request.status),
    );
  }

  Widget _status(RequestStatus status) {
    final data = {
      RequestStatus.resolved: (
        'Resolved',
        const Color(0xff0d9b70),
        const Color(0xffe5fbf3),
      ),
      RequestStatus.inProgress: (
        'In Progress',
        const Color(0xff2877e8),
        const Color(0xffeaf2ff),
      ),
      RequestStatus.pending: (
        'Pending',
        const Color(0xffd37a00),
        const Color(0xfffff4df),
      ),
    }[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: data.$3,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        data.$1,
        style: TextStyle(
          fontSize: 9,
          color: data.$2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _pagination() {
    final start = filteredRequests.isEmpty
        ? 0
        : (currentPage - 1) * pageSize + 1;
    final end = (currentPage * pageSize).clamp(0, filteredRequests.length);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Text(
            'Showing $start to $end of ${filteredRequests.length} entries',
            style: const TextStyle(fontSize: 10, color: Color(0xff66768e)),
          ),
          const Spacer(),
          IconButton(
            onPressed: currentPage > 1
                ? () => setState(() => currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left, size: 18),
          ),
          Text(
            '$currentPage / $pageCount',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
          IconButton(
            onPressed: currentPage < pageCount
                ? () => setState(() => currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right, size: 18),
          ),
        ],
      ),
    );
  }
}

class _RequestHeader extends StatelessWidget {
  const _RequestHeader();

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xffe3e8ee))),
    ),
    child: Row(
      children: [
        const Icon(Icons.dashboard_outlined, color: Color(0xff1b2b42)),
        const SizedBox(width: 9),
        const Text(
          'ICT Help Desk',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xff172841),
          ),
        ),
        const SizedBox(width: 13),
        const Text(
          'DATA PORTAL',
          style: TextStyle(
            fontSize: 8,
            letterSpacing: .8,
            color: Color(0xff64738a),
          ),
        ),
        const Spacer(),
        const Text(
          'AUTHORIZED STAFF ONLY',
          style: TextStyle(
            fontSize: 8,
            letterSpacing: .8,
            color: Color(0xff64738a),
          ),
        ),
        const SizedBox(width: 22),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Lock Portal'),
        ),
      ],
    ),
  );
}
