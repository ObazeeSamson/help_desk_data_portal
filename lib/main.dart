import 'package:flutter/material.dart';
import 'package:help_desk_data_portal/screens/password_screen/password_screen.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

/// Entry point of the ICT Help Desk Data Portal application.
void main() {
  runApp(const MyApp());
}

/// The root application widget.
///
/// Sets up:
/// - Application title
/// - Global theme configuration ([AppTheme.lightTheme])
/// - Initial authentication landing screen ([PasswordScreen])
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICT Help Desk Data Portal',
      // Hide the debug banner in the top-right corner for a clean presentation
      debugShowCheckedModeBanner: false,
      // Apply custom brand green theme with Inter typography
      theme: AppTheme.lightTheme,
      // Initial route requires password verification before accessing requests
      home: const PasswordScreen(),
    );
  }
}
