import 'package:flutter/material.dart';
import 'UserRegistration/loginPage.dart';
import 'genre_analytics_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GenreAnalyticsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BingeSwipe',
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


