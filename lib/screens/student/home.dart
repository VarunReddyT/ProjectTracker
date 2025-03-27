import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:project_tracker/screens/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> projects = [];
  bool _isLoading = true;
  String? studentRollNo;
  String? studentName;
  String? userId;
  List<dynamic> chatRooms = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void goToProject(Map<String, dynamic> project) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('projectId', project['_id']);
    await prefs.setString('projectTitle', project['projectTitle']);
    await prefs.setString('projectDescription', project['projectDescription']);
    await prefs.setString('projectStatus', project['projectStatus']);
    await prefs.setString('projectDomain', project['projectDomain']);
    await prefs.setString('projectType', project['projectType']);
    if (project['studentRollNo'] == null) {
      await prefs.setString('teamId', project['teamId']);
      await prefs.setString('projectStartDate', project['projectStartDate']);
    }
    if (mounted) {
      Navigator.pushNamed(context, '/project');
    }
  }

  void addProject() async {
    var result = await Navigator.pushNamed(context, '/addProject');
    if (result == true) {
      fetchData();
    }
  }

  Future<void> fetchChatRooms() async {
    if (userId == null) {
      return;
    }
    try {
      var response = await http.get(Uri.parse(
          'https://ps-project-tracker.vercel.app/api/user/getChatIds/$userId'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data is List) {
          if (mounted) {
            setState(() {
              chatRooms = List<Map<String, dynamic>>.from(data);
            });
          }
          if (chatRooms.isNotEmpty && mounted) {
            Navigator.pushNamed(context, '/chat',
                arguments: chatRooms[0]['_id']);
          }
        }
      } else {
        throw Exception(
            'Failed to load chat rooms. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    studentRollNo = prefs.getString('studentRollNo');
    studentName = prefs.getString('studentName');
    userId = prefs.getString('studentId');
    if (studentRollNo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Student data not found. Please log in again.')),
        );
      }
      return;
    }

    try {
      var response = await http.get(Uri.parse(
          'https://ps-project-tracker.vercel.app/api/project/getOngoingProjects/$studentRollNo'));

      var data = jsonDecode(response.body);
      if (data is List) {
        setState(() {
          projects = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (err) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'My Projects',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              accountName: Text(studentName ?? 'Student'),
              accountEmail: Text(studentRollNo ?? 'Roll No'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => {
                      Navigator.pop(context),
                      Navigator.pushNamed(context, '/settings'),
                    }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: projects.isEmpty
                  ? const Center(child: Text('No Projects Found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: projects.length,
                      itemBuilder: (context, index) => Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            projects[index]['projectTitle'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.blue),
                          onTap: () {
                            goToProject(projects[index]);
                          },
                        ),
                      ),
                    ),
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     addProject();
      //   },
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchChatRooms();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
