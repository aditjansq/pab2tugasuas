import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pabtugasuas/screens/sign_in_screen.dart'; // Import SignInScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preloved Store', // App title
      debugShowCheckedModeBanner: false, // Disable the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SignInScreen(), // Set SignInScreen as the home screen
    );
  }
}
