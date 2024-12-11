import 'package:flutter/material.dart';
import 'package:project_tracker/screens/home.dart';
import 'package:project_tracker/screens/login.dart';
import 'package:project_tracker/screens/project.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const Login(),
        '/home': (context) => const Home(),
        '/project': (context) => const Project(),
      },
    );
  }
}