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
} //
