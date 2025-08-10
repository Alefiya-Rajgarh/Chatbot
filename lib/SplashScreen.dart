
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chatbot/chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Wait for a specified duration
    await Future.delayed(const Duration(seconds: 3), () {}); // Adjust duration as needed

    // Navigate to the ChatScreen and replace the splash screen in the navigation stack
    if (mounted) { // Check if the widget is still in the tree
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Light Purple - matches your app theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/bot.jpg', // Replace with your actual icon asset path
              width: screenWidth * 0.4, // Responsive width
              height: screenHeight * 0.2, // Responsive height
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            // App Name Text
            const Text(
              "Alefiya's Chat Bot",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900, // Matching your AppBar title style
                color: Color(0xFF9575CD),    // DeepPurpleAccent - matching your AppBar title
              ),
            ),
            const SizedBox(height: 16),
            // Optional: Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF9575CD).withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
