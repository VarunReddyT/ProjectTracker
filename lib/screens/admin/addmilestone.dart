import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Addmilestone extends StatefulWidget {
  const Addmilestone({super.key});

  @override
  State<Addmilestone> createState() => _AddmilestoneState();
}

class _AddmilestoneState extends State<Addmilestone> {
  TextEditingController _milestoneName = TextEditingController();
  TextEditingController _milestoneDescription = TextEditingController();
  TextEditingController _milestoneStartDate = TextEditingController();
  TextEditingController _milestoneEndDate = TextEditingController();

  List<dynamic> projects = [];
  bool isLoading = false;

  void fetchProjects(int year) async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.get(Uri.parse(
          'https://ps-project-tracker.vercel.app/api/project/getYearProjects/$year'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          projects.clear();
          projects.addAll(data);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to fetch projects")));
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch projects : $e")));
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSearch(String projectId, String projectTitle) async {
    var storage = const FlutterSecureStorage();
    await storage.write(key: 'currentProjectId', value: projectId);
    await storage.write(key: 'currentProjectTitle', value: projectTitle);
    if(mounted){
      Navigator.pushNamed(context, '/viewProjectMilestones');
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void showMilestoneModal(String projectId, String projectTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Center(
                child: Text(
                  'Milestones',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    const Text(
                      'Milestone Name',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _milestoneName,
                      decoration: InputDecoration(
                        hintText: 'Enter milestone name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Milestone Description',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _milestoneDescription,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter milestone description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Start Date',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _milestoneStartDate,
                      readOnly: true,
                      onTap: () {
                        _pickDate(_milestoneStartDate);
                      },
                      decoration: InputDecoration(
                        hintText: 'Select start date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'End Date',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _milestoneEndDate,
                      readOnly: true,
                      onTap: () {
                        _pickDate(_milestoneEndDate);
                      },
                      decoration: InputDecoration(
                        hintText: 'Select end date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Add milestone logic here
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Add Milestone',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  handleSearch(projectId, projectTitle);
                },
                child: const Icon(Icons.manage_search_rounded),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Milestone"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField(
                items: [1, 2, 3, 4].map((int year) {
                  return DropdownMenuItem<int>(
                      value: year, child: Text('$year'));
                }).toList(),
                onChanged: (int? value) {
                  fetchProjects(value!);
                },
              ),
              const SizedBox(height: 16),
              projects.isEmpty && !isLoading
                  ? const Text('No projects available')
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
                                  showMilestoneModal(projects[index]['_id'], projects[index]['projectTitle']);
                                },
                              ),
                            );
                          })
            ],
          ),
        ),
      ),
    );
  }
}
