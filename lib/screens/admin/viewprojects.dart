import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Viewprojects extends StatefulWidget {
  const Viewprojects({super.key});

  @override
  State<Viewprojects> createState() => _ViewprojectsState();
}

class _ViewprojectsState extends State<Viewprojects> {
  List<dynamic> projects = [];
  bool isLoading = false;
  bool isInit = true;

  void fetchProjects(int year) async {
    setState(() {
      isLoading = true;
      isInit = false;
    });
    try {
      var response = await http.get(Uri.parse(
          '${dotenv.env['API_KEY']}/api/project/getYearProjects/$year'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          projects.clear();
          projects.addAll(data);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to fetch projects')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch projects: $e')));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showProjectDetailsModal(BuildContext context, dynamic project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['projectTitle'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Type: ${project['projectType']}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description: ${project['projectDescription']}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Domain: ${project['projectDomain']}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Technologies: ${project['projectTechnologies'].join(', ')}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${project['projectStatus']}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  project['projectType'] == 'Academic'
                      ? 'Team: ${project['teamId']['teamName']}'
                      : 'Student Roll No : ${project['studentRollNo']}',

                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Team Year: ${project['teamYear'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
              child: DropdownButtonFormField<int>(
                items: [1, 2, 3, 4].map((int year) {
                  return DropdownMenuItem<int>(
                      value: year, child: Text('$year'));
                }).toList(),
                onChanged: (year) {
                  setState(() {
                    fetchProjects(year!);
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Year',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            isInit
                ? const Center(
                    child: Text(
                    'Select a year to view projects',
                    textAlign: TextAlign.center,
                  ))
                : isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: projects.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                projects[index]['projectTitle'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                projects[index]['projectDescription'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                _showProjectDetailsModal(
                                    context, projects[index]);
                              },
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
