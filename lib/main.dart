import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_tracker/screens/login.dart';
import 'package:project_tracker/screens/student/home.dart';
import 'package:project_tracker/screens/student/project.dart';
import 'package:project_tracker/screens/student/tasks.dart';
import 'package:project_tracker/screens/student/milestones.dart';
import 'package:project_tracker/screens/student/share.dart';
import 'package:project_tracker/screens/student/team.dart';
import 'package:project_tracker/screens/admin/admin.dart';
import 'package:project_tracker/screens/admin/addacademicproject.dart';
import 'package:project_tracker/screens/admin/addmilestone.dart';
import 'package:project_tracker/screens/admin/addteam.dart' as admin_addteam;
import 'package:project_tracker/screens/admin/assignproject.dart';
import 'package:project_tracker/screens/admin/viewprojects.dart';
import 'package:project_tracker/screens/admin/viewteams.dart';
import 'package:project_tracker/screens/admin/addstudent.dart';
import 'package:project_tracker/screens/settings.dart';
import 'package:project_tracker/screens/admin/viewmilestones.dart';
import 'package:project_tracker/screens/student/addproject.dart';
import 'package:project_tracker/screens/services/socket_service.dart';
import 'package:project_tracker/screens/services/chat.dart';
import 'package:project_tracker/screens/services/project_selection_service.dart';
import 'package:project_tracker/screens/admin/manageprojectselection.dart';
import 'package:project_tracker/screens/student/projectselection.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async{
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SocketService('ws:${dotenv.env['IP_ADDR']}:4000'),
        ),
        ChangeNotifierProvider(
          create: (context) => ProjectSelectionService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/home': (context) => const Home(),
        '/project': (context) => const Project(),
        '/tasks': (context) => const Tasks(),
        '/milestones': (context) => const Milestones(),
        '/addProject': (context) => const AddProject(),
        '/projectSelection': (context) => const ProjectSelection(),
        '/share': (context) => const Share(),
        '/team': (context) => const Team(),
        '/settings': (context) => const Settings(),
        '/admin': (context) => const Admin(),
        '/addAcademicProject': (context) => const Addacademicproject(),
        '/addStudent': (context) => const Addstudent(),
        '/assignProject': (context) => const AssignProject(),
        '/addMilestone': (context) => const Addmilestone(),
        '/addTeam': (context) => const admin_addteam.Addteam(),
        '/viewTeams': (context) => const Viewteams(),
        '/viewProjects': (context) => const Viewprojects(),
        '/viewProjectMilestones': (context) => const Viewmilestones(),
        '/manageProjectSelection': (context) => const ManageProjectSelection(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final chatRoomId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(chatRoomId: chatRoomId),
          );
        }
        return null;
      },
    );
  }
}
