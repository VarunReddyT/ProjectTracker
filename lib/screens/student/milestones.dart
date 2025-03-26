import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Milestones extends StatefulWidget {
  const Milestones({super.key});

  @override
  State<Milestones> createState() => _MilestonesState();
}

class _MilestonesState extends State<Milestones> {
  @override
  void initState() {
    super.initState();
    getMilestones();
  }

  TextEditingController milestoneUrlController = TextEditingController();

  List<dynamic> milestones = [];
  bool isLoading = true;

  void getMilestones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var projectId = prefs.getString('projectId');

      if (projectId == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project ID not found. Please try again.'),
            ),
          );
        }
        return;
      }

      var response = await http.get(
        Uri.parse(
            'https://ps-project-tracker.vercel.app/api/milestone/getMilestone/$projectId'),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            milestones = data;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Error fetching milestones: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching milestones: $e'),
          ),
        );
      }
    }
  }

 void addMilestone() async {
    final prefs = await SharedPreferences.getInstance();
    String? studentRollNo = prefs.getString('studentRollNo');
    String? projectId = prefs.getString('projectId');

    if (studentRollNo == null || projectId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student or project data not found. Please log in again.'),
          ),
        );
      }
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('https://ps-project-tracker.vercel.app/api/milestone/addMilestone'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'milestoneUrl': milestoneUrlController.text,
          'projectId': projectId,
          'studentRollNo': studentRollNo
        }),
      );
      if (response.statusCode == 200) {
        milestoneUrlController.clear();
        getMilestones();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Milestone added successfully'),
              backgroundColor: Color.fromARGB(255, 59, 180, 63),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add milestone: ${response.body}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add milestone: $e'),
          ),
        );
      }
    }
  }

  // Function to show the modal with milestone details
  void showMilestoneDetails(dynamic milestone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(milestone['milestoneName']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description:'),
                Text(milestone['milestoneDescription']),
                SizedBox(height: 8),
                Text('Start Date: ${milestone['milestoneStartDate']}'),
                Text('End Date: ${milestone['milestoneEndDate']}'),
                SizedBox(height: 8),
                Text('Student Details:'),
                ...milestone['studentDetails'].map<Widget>((student) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Roll No: ${student['studentRollNo']}'),
                      Text('URL: ${student['mileStoneUrl']}'),
                      Text(
                          'Status: ${student['mileStoneStatus'] ? 'Completed' : 'Pending'}'),
                      SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : milestones.isEmpty
              ? const Center(
                  child: Text(
                    'No milestones available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    var milestone = milestones[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              milestone['milestoneName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              milestone['milestoneDescription'],
                              style: TextStyle(color: Colors.blue),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_right_outlined),
                              onPressed: () {
                               
                              },
                            ),
                            onTap: () {
                              showMilestoneDetails(milestone);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
