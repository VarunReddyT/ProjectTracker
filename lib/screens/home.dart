import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String,dynamic>> projects = [];
  bool _isLoading = true;
  String? studentRollNo;
  String? studentName;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void goToProject(Map<String,dynamic> project) async {
     const storage = FlutterSecureStorage();
      await storage.write(key: 'projectId', value: project['_id']);
      await storage.write(key: 'projectTitle', value: project['projectTitle']);
      await storage.write(key: 'projectDescription', value: project['projectDescription']);
      await storage.write(key: 'projectStatus', value: project['projectStatus']);
      await storage.write(key: 'projectDomain', value: project['projectDomain']);
      if(project['studentRollNo'] == null){
        await storage.write(key:'teamId', value: project['teamId']);
        await storage.write(key:'projectStartDate', value: project['projectStartDate']);
      }
      if(mounted){
        Navigator.pushNamed(context, '/project');
      }
  }

  void fetchData() async {
    const storage = FlutterSecureStorage();
    studentRollNo = await storage.read(key: 'studentRollNo');
    studentName = await storage.read(key: 'studentName');
    
    try {
      var response = await http.get(Uri.parse(
          'http://localhost:4000/api/project/getOngoingProjects/$studentRollNo'));

      var data = jsonDecode(response.body);
      if (data is List) {
        setState(() {
          projects = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (err) {
      setState(() => _isLoading = false);
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red)
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
          style: TextStyle(
            color: Colors.black87, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {},
          ),
        ],
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
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : projects.isEmpty
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
                  trailing: const Icon(Icons.chevron_right, color: Colors.blue),
                  onTap: () {
                      goToProject(projects[index]);
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
    );
  }
}