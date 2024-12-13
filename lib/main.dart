import 'package:flutter/material.dart';
import 'UserRegistration/loginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BingeSwipe',
      home: const LoginPage(), // Start with the LoginPage
      debugShowCheckedModeBanner: false,
    );
  }
}


