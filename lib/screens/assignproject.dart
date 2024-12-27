import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssignProject extends StatefulWidget {
  const AssignProject({super.key});

  @override
  State<AssignProject> createState() => _AssignProjectState();
}

class _AssignProjectState extends State<AssignProject> {
  int? selectedYear;
  String? selectedTeam;
  final List<int> years = [1, 2, 3, 4];
  final List<String> teams = [];
  final List<dynamic> teamData = [];
  final List<dynamic> projects = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  void fetchTeams(int year) async {
    try {
      var response = await http.get(Uri.parse(
          'https://ps-project-tracker.vercel.app/api/team/getUnassignedTeams/$year'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          teams.clear();
          teamData.clear();
          for (var team in data) {
            teams.add(team['teamName']);
          }
          teamData.addAll(data);
          selectedTeam = null;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to fetch teams')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch teams : $e')));
      }
    }
  }

  void fetchProjects() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.get(Uri.parse(
          'https://ps-project-tracker.vercel.app/api/project/getUnassignedProjects'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          projects.clear();
          projects.addAll(data);
          isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to fetch projects')));
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch projects : $e')));
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showAssignModal(dynamic project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assign Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                value: selectedYear,
                hint: const Text('Year'),
                items: years.map((int year) {
                  return DropdownMenuItem<int>(
                      value: year, child: Text('$year'));
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    selectedYear = value;
                  });
                  if (value != null) {
                    fetchTeams(value);
                  }
                },
              ),
              const SizedBox(height: 20),
              teams.isEmpty
                  ? const Center(child: Text('No teams available'))
                  :
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Team',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                ),
                value: selectedTeam,
                hint: const Text('Team'),
                items: teams.map((String team) {
                  return DropdownMenuItem<String>(
                    value: team,
                    child: Text(team),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedTeam = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {

                // ^^^^ To do: Assign project to selected team
              },
              child: const Text('Assign'),
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
        title: const Text('Assign Project'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        var project = projects[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project['projectTitle'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        project['projectDescription'] ?? 'No description',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    showAssignModal(project);
                                  },
                                  child: const Text('Assign'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
