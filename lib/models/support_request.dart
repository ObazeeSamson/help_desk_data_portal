/// Represents the operational lifecycle status of a support request.
enum RequestStatus {
  /// Request has been fulfilled and completed.
  resolved,

  /// Request is actively being worked on by ICT personnel.
  inProgress,

  /// Request is newly submitted and awaiting technician assignment or action.
  pending;

  /// Serializes the status enum to the string expected by the MySQL backend.
  String get backendValue {
    switch (this) {
      case RequestStatus.inProgress:
        return 'in_progress';
      case RequestStatus.resolved:
        return 'resolved';
      case RequestStatus.pending:
        return 'pending';
    }
  }
}

/// Domain model representing a single ICT Help Desk support ticket.
///
/// Encapsulates ticket information retrieved from the backend MySQL database
/// (`help_requests` table).
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

  /// Unique numerical database identifier for the ticket (e.g. "12").
  final String ticketId;

  /// Current resolution status (pending, inProgress, resolved).
  final RequestStatus status;

  /// The organizational department that submitted the request (e.g. "Finance").
  final String department;

  /// Physical room number or internal phone extension (e.g. "Room 304 / Ext 441").
  final String location;

  /// Full name of the officer requesting assistance.
  final String officer;

  /// Job title or official designation of the requester (e.g. "HOD", "Accountant").
  final String designation;

  /// Detailed description of the hardware, software, or network issue.
  final String description;

  /// ICT staff or technician assigned to diagnose and fix the problem.
  final String diagnosedBy;

  /// Timestamp when the ticket was initially logged.
  final DateTime createdAt;

  /// Deserializes a JSON map from the backend REST API into a [SupportRequest] instance.
  ///
  /// Provides safe fallbacks for missing or null fields to prevent runtime exceptions.
  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    // Helper function to map MySQL string values ('pending', 'in_progress', 'resolved')
    // to the strongly typed [RequestStatus] enum.
    RequestStatus parseStatus(String? val) {
      final s = (val ?? '').toLowerCase();
      if (s.contains('progress')) return RequestStatus.inProgress;
      if (s.contains('resolved')) return RequestStatus.resolved;
      return RequestStatus.pending;
    }

    // Handles either 'created_at' or legacy 'create' column naming variations in MySQL
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
