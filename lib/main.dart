import 'package:flutter/material.dart';
import 'package:homify/auth/login.dart';
import 'package:homify/theme/theme_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
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
