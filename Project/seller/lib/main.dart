import 'package:flutter/material.dart';
import 'package:seller/dashbord.dart';
import 'package:seller/Product.dart';
import 'package:seller/login.dart';
import 'package:seller/registra.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://eoetwqhtrlichezrhoqt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvZXR3cWh0cmxpY2hlenJob3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxOTQ1NzksImV4cCI6MjA1Mjc3MDU3OX0.2Pwx4Uwej0bR8uoiXCk5NrQQ-TJ8yNv1CJASccZc9mI',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          AuthWrapper(), // Use the AuthWrapper widget to manage authentication state
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in

    final session = supabase.auth.currentSession;

    // Navigate to the appropriate screen based on the authentication state

    if (session != null) {
      return Registra(); // Replace with your home screen widget
    } else {
      return Registra(); // Replace with your auth page widget
    }
  }
}
