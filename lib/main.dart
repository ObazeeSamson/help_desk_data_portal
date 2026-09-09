import 'package:flutter/material.dart';

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
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xfff5f7fa),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff101b30)),
      ),
      home: const PasswordScreen(),
    );
  }
}
