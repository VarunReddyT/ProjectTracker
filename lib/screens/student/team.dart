import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Team extends StatefulWidget {
  const Team({super.key});

  @override
  State<Team> createState() => _TeamState();
}

class _TeamState extends State<Team> {
  List<String> teamMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeam();
  }

  void fetchTeam() async {
    final prefs = await SharedPreferences.getInstance();
    var teamMembersString = prefs.getString('teamMembers');
    setState(() {
      teamMembers = teamMembersString != null
          ? List<String>.from(jsonDecode(teamMembersString))
          : [];
      isLoading = false;
    });
  }

  void getStudentDetails(studentRollNo) async {
    try {
      final prefs = await SharedPreferences.getInstance(); 
      var teamId = prefs.getString('teamId');

      var response = await http.get(Uri.parse(
          '${dotenv.env['API_KEY']}/api/team/getStudentDetails/$studentRollNo/$teamId'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var studentName = data['studentName'];
        var studentBranch = data['studentBranch'];
        var studentYear = data['studentYear'];
        var studentSection = data['studentSection'];
        var studentSemester = data['studentSemester'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.indigo,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'Student Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.indigo),
                  title: Text(
                    studentName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('$studentRollNo'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.school, color: Colors.indigo),
                  title: Text(
                    '$studentBranch',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                      'Year: $studentYear-$studentSemester'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.group, color: Colors.indigo),
                  title: Text(
                    'Section: $studentSection',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error fetching student details: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching student details: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? ListView.builder(
                itemCount: teamMembers.length,
                itemBuilder: (context, index) => _buildShimmerEffect(),
              )
            : teamMembers.isEmpty
                ? Center(
                    child: Text(
                      'No Team Members Found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: teamMembers.length,
                    itemBuilder: (context, index) {
                      return _buildTeamMemberTile(teamMembers[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 16,
            width: 200,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberTile(String memberName) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Text(
            memberName.isNotEmpty
                ? memberName[memberName.length - 2].toUpperCase() +
                    memberName[memberName.length - 1].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          memberName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            getStudentDetails(memberName);
          },
        ),
      ),
    );
  }
}
