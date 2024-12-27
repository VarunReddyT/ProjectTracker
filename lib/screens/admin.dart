import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_tracker/screens/login.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String? username;
  String? email;
  void fetchData() async {
    const storage = FlutterSecureStorage();
    var username = await storage.read(key: 'username');
    var email = await storage.read(key: 'email');
    setState(() {
      this.username = username;
      this.email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              accountName: Text(username ?? 'Admin'),
              accountEmail: Text(email ?? 'Email'),
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
              onTap: () {
                const storage = FlutterSecureStorage();
                storage.deleteAll();
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(13.0, 20, 13.0, 20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: [
            _buildGridItem('Add Project', Icons.add_circle_outline_rounded, context, "/addAcademicProject"),
            _buildGridItem('Add Student', Icons.person_add_alt_1_outlined, context, "/addStudent"),
            _buildGridItem('Assign Project', Icons.assignment_turned_in_outlined, context, "/assignProject"),
            _buildGridItem('Add Milestone', Icons.flag_outlined, context, "/addMilestone"),
            _buildGridItem('Add Team', Icons.group_add_outlined, context, "/addTeam"),
            _buildGridItem('View Teams', Icons.groups_outlined, context, "/viewTeams"),
            _buildGridItem('View Projects', Icons.grid_view_outlined, context, "/viewProjects"),
          ],
        ),
      ),
    );
  }
}

Widget _buildGridItem(String title, IconData icon, BuildContext context, String route) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, route);
    },
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
        
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    ),
  );
}
