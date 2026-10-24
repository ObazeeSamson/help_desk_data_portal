import 'dart:convert';

import 'package:help_desk_data_portal/constants.dart';
import 'package:help_desk_data_portal/models/support_request.dart';
import 'package:http/http.dart' as http;

/// Centralized service handling all HTTP network communication with the PHP backend.
///
/// Encapsulates authentication, fetching tickets, updating ticket statuses,
/// deleting tickets, and generating CSV exports. UI widgets and screens should
/// interact with the backend exclusively via these static methods.
class HelpDeskService {
  // Base URL pointing to the active backend server (AlwaysData / local).
  static const String _base = AppConstants.apiBase;

  // ── Authentication ────────────────────────────────────────────────────────

  /// Verifies the administrative portal password against the backend.
  ///
  /// Sends a POST request with [password] to `verify_password.php`.
  /// Returns `true` if the server confirms authentication with "success",
  /// or `false` if the password does not match.
  /// Throws an [Exception] if the HTTP request fails.
  static Future<bool> verifyPassword(String password) async {
    final response = await http.post(
      Uri.parse('$_base/verify_password.php'),
      body: {'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return response.body.trim() == 'success';
  }

  // ── Support Request Data ──────────────────────────────────────────────────

  /// Fetches all logged support tickets from the MySQL database.
  ///
  /// Sends a GET request to `get_requests.php`.
  /// Parses the returned JSON payload and maps each item to a [SupportRequest].
  /// Throws an [Exception] if network or server error occurs.
  static Future<List<SupportRequest>> fetchRequests() async {
    final response = await http.get(
      Uri.parse('$_base/get_requests.php'),
    );

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['status'] != 'success') {
      throw Exception('API returned non-success status.');
    }

    final List rawList = decoded['data'] ?? [];
    return rawList
        .map((item) => SupportRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Updates the lifecycle status of a support ticket.
  ///
  /// Sends a POST request to `update_status.php` with:
  /// - [id]: The database record ID of the ticket.
  /// - [status]: The target status string ('pending', 'in_progress', or 'resolved').
  /// - [diagnosedBy]: Optional technician name assigned to diagnose/resolve the issue.
  /// Throws an [Exception] if update fails on the backend.
  static Future<void> updateStatus(
    String id,
    String status, {
    String? diagnosedBy,
  }) async {
    final body = <String, String>{
      'id': id,
      'status': status,
    };
    if (diagnosedBy != null && diagnosedBy.trim().isNotEmpty) {
      body['diagnosed_by'] = diagnosedBy.trim();
    }

    final response = await http.post(
      Uri.parse('$_base/update_status.php'),
      body: body,
    );

    if (response.statusCode != 200 || response.body.trim() != 'success') {
      throw Exception('Failed to update status: ${response.body}');
    }
  }

  /// Directly assigns or reassigns a technician to a support ticket.
  ///
  /// Sends a POST request to `update_status.php` with:
  /// - [id]: The database record ID of the ticket.
  /// - [diagnosedBy]: Full name of the technician being assigned.
  /// - [status]: Optional status to maintain.
  /// Throws an [Exception] if assignment fails on the backend.
  static Future<void> assignTechnician(
    String id,
    String diagnosedBy, {
    String? status,
  }) async {
    final body = <String, String>{
      'id': id,
      'diagnosed_by': diagnosedBy.trim(),
    };
    if (status != null && status.isNotEmpty) {
      body['status'] = status;
    }

    final response = await http.post(
      Uri.parse('$_base/update_status.php'),
      body: body,
    );

    if (response.statusCode != 200 || response.body.trim() != 'success') {
      throw Exception('Server returned ${response.statusCode}: ${response.body}');
    }
  }

  /// Permanently deletes a support ticket by its database record [id].
  ///
  /// Sends a POST request to `delete_request.php`.
  /// Throws an [Exception] if deletion fails on the backend.
  static Future<void> deleteRequest(String id) async {
    final response = await http.post(
      Uri.parse('$_base/delete_request.php'),
      body: {'id': id},
    );

    if (response.statusCode != 200 || response.body.trim() != 'success') {
      throw Exception('Failed to delete request.');
    }
  }

}
