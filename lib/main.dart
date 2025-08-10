import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chatbot/chat_screen.dart';
import 'package:chatbot/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alefiya\'s Chat Bot',
      theme: ThemeData( // Your existing theme
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9575CD),
          background: const Color(0xFFF3E5F5),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple.shade300,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple.shade300,
          brightness: Brightness.dark,
          background: const Color(0xFF303030),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(), // Start with SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}