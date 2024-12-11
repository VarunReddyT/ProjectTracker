import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Project extends StatefulWidget {
  const Project({super.key});

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  String? projectId;
  String? projectTitle;
  String? projectDescription;
  String? projectStatus;
  String? projectDomain;
  String? teamId;
  String? projectStartDate;
  List<String> teamMembers = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    const storage = FlutterSecureStorage();
    var projectId = await storage.read(key: 'projectId');
    var projectTitle = await storage.read(key: 'projectTitle');
    var projectDescription = await storage.read(key: 'projectDescription');
    var projectStatus = await storage.read(key: 'projectStatus');
    var projectDomain = await storage.read(key: 'projectDomain');
    var teamId = await storage.read(key: 'teamId');
    var projectStartDate = await storage.read(key: 'projectStartDate');

    if (teamId != null) {
      try {
        var response = await http.get(Uri.parse('http://localhost:4000/api/team/getTeam/$teamId'));
        var data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          for (var member in data['teamMembers']) {
            teamMembers.add(member);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch team members'),
            ),
          );
        }
      }
    }

    setState(() {
      this.projectId = projectId;
      this.projectTitle = projectTitle;
      this.projectDescription = projectDescription;
      this.projectStatus = projectStatus;
      this.projectDomain = projectDomain;
      this.teamId = teamId;
      this.projectStartDate = projectStartDate;
    });
  }

  @override
  void dispose() {
    clearStorage();
    super.dispose();
  }

  void clearStorage() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'projectId');
    await storage.delete(key: 'projectTitle');
    await storage.delete(key: 'projectDescription');
    await storage.delete(key: 'projectStatus');
    await storage.delete(key: 'projectDomain');
    await storage.delete(key: 'teamId');
    await storage.delete(key: 'projectStartDate');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Title
                Center(
                  child: Text(
                    projectTitle ?? 'No Project Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Project Details Table
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    // _buildTableRow('Project ID', projectId),
                    _buildTableRow('Description', projectDescription),
                    _buildTableRow('Status', projectStatus),
                    _buildTableRow('Domain', projectDomain),
                    // _buildTableRow('Team ID', teamId),
                    _buildTableRow('Start Date', projectStartDate),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Buttons
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here
        },
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          'Add Task',
          style: TextStyle(
            // Adjust size to fit well
            color: Colors.white, // Ensure contrast with button color
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper method to build table rows
  TableRow _buildTableRow(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            value ?? 'Not Available',
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
