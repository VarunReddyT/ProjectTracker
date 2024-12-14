import 'package:flutter/material.dart';
import 'package:project_tracker/screens/home.dart';
import 'package:project_tracker/screens/login.dart';
import 'package:project_tracker/screens/project.dart';
import 'package:project_tracker/screens/tasks.dart';
import 'package:project_tracker/screens/milestones.dart';
import 'package:project_tracker/screens/addproject.dart';

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
        '/tasks': (context) => const Tasks(),
        '/milestones': (context) => const Milestones(),
        '/addProject': (context) => const AddProject(),
      },
    );
  }
}