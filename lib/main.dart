import 'package:flutter/material.dart';
import 'package:project_tracker/screens/home.dart';
import 'package:project_tracker/screens/login.dart';
import 'package:project_tracker/screens/project.dart';
import 'package:project_tracker/screens/tasks.dart';
import 'package:project_tracker/screens/milestones.dart';
import 'package:project_tracker/screens/addproject.dart';
import 'package:project_tracker/screens/share.dart';
import 'package:project_tracker/screens/team.dart';
import 'package:project_tracker/screens/admin.dart';
import 'package:project_tracker/screens/addacademicproject.dart';
import 'package:project_tracker/screens/addmilestone.dart';
import 'package:project_tracker/screens/addteam.dart';
import 'package:project_tracker/screens/assignproject.dart';
import 'package:project_tracker/screens/viewprojects.dart';
import 'package:project_tracker/screens/viewteams.dart';
import 'package:project_tracker/screens/addstudent.dart';
import 'package:project_tracker/screens/settings.dart';



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
        '/share': (context) => const Share(),
        '/team': (context) => const Team(),
        '/settings': (context) => const Settings(),

        '/admin': (context) => const Admin(),
        '/addAcademicProject': (context) => const Addacademicproject(),
        '/addStudent': (context) => const Addstudent(),
        '/assignProject': (context) => const Assignproject(),
        '/addMilestone': (context) => const Addmilestone(),
        '/addTeam': (context) => const Addteam(),
        '/viewTeams': (context) => const Viewteams(),
        '/viewProjects': (context) => const Viewprojects(),

      },
    );
  }
}