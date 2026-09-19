import 'package:flutter/material.dart';
import 'package:help_desk_data_portal/theme/app_theme.dart';

import 'screens/password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PasswordScreen(),
    );
  }
}
