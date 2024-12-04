import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';   
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  List<String> projects = [];

  void fetchData() async {
    const storage = FlutterSecureStorage();
    String? projectIdsString = await storage.read(key: 'projectIds');
    if(projectIdsString != null){
      List<dynamic> projectIds = jsonDecode(projectIdsString);
    }
    // try{
    //   var response = await http.get(Uri.parse('http://localhost:4000/api/project/getOngoingProjects/:userId'));
    // }

  }
  final List<String> _list = ['Home', 'Profile', 'Settings', 'Logout'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: GFDrawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const GFDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Icon(
                    Icons.account_circle,
                    size: 100,
                  ),
                ),
              ),
            ),         
            ListTile(
              title: const Text('Profile'),
              trailing : const Icon(
                Icons.account_circle_rounded,
              ),
              onTap: () {
                // Add functionality here if needed
              },
            ),
            ListTile(
              title: const Text('Settings'),
              trailing: const Icon(
                Icons.settings,
              ),
              onTap: () {
                // Add functionality here if needed
              },
            ),
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              onTap: () {
                // Add functionality here if needed
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: _list.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_list[index]),
                  onTap: () {
                    // Add functionality here if needed
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
