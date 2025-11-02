import 'package:flutter/material.dart';
import 'package:homify/pages/login.dart';
import 'package:homify/theme/theme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: LoginPage(),
    );
  }
}
