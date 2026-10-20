/// App-wide configuration constants.
///
/// This file acts as the single source of truth for global configuration values,
/// such as API endpoints and backend URLs.
class AppConstants {
  // Private constructor prevents instantiation of this utility class.
  AppConstants._();

  /// The root URL for all Help Desk REST API endpoints.
  ///
  /// - Production (AlwaysData): 'https://npa-helpdesk-requestform.alwaysdata.net/help_desk_request'
  static const String apiBase =
      'https://npa-helpdesk-requestform.alwaysdata.net/help_desk_request';
}
