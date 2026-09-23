import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:help_desk_data_portal/models/status_request.dart';

class RequestService {
  static const String baseUrl = 'http://localhost/help_desk_request';

  Future<void> fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/get_requests.php'));

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
}
