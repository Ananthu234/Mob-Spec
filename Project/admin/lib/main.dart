import 'package:admin/dashboard.dart';
import 'package:admin/district.dart';
import 'package:admin/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
Future<void> main() async {
   await Supabase.initialize(
    url: 'https://eoetwqhtrlichezrhoqt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvZXR3cWh0cmxpY2hlenJob3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxOTQ1NzksImV4cCI6MjA1Mjc3MDU3OX0.2Pwx4Uwej0bR8uoiXCk5NrQQ-TJ8yNv1CJASccZc9mI',
  );
  runApp(const MainApp());
}
final supabase=Supabase.instance.client;
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}
