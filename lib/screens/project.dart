import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Project extends StatefulWidget {
  const Project({super.key});

  @override
  State<Project> createState() => _ProjectState();
}

class _ChartData {
  final String label;
  final int value;

  _ChartData(this.label, this.value);
}

class _ProjectState extends State<Project> {
  String? projectId;
  String? projectTitle;
  String? projectDescription;
  String? projectStatus;
  String? projectDomain;
  String? teamId;
  String? projectStartDate;
  String? projectType;
  List<String> teamMembers = [];
  bool _isLoading = false;
  int completedTasks = 0;
  int pendingTasks = 0;

  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchTaskStatus(String? studentRollNo, String? projectId) async {
    try {
      var response = await http.get(Uri.parse(
          'http://192.168.0.161:4000/api/task/getTaskStatuses/$studentRollNo/$projectId'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          completedTasks = data['completed'];
          pendingTasks = data['ongoing'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch task statuses : ${response.body}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch task statuses : ${e.toString()}'),
          ),
        );
      }
    }
  }

  void fetchData() async {
    setState(() {
      _isLoading = true;
    });
    const storage = FlutterSecureStorage();
    var projectId = await storage.read(key: 'projectId');
    var projectTitle = await storage.read(key: 'projectTitle');
    var projectDescription = await storage.read(key: 'projectDescription');
    var projectStatus = await storage.read(key: 'projectStatus');
    var projectDomain = await storage.read(key: 'projectDomain');
    var teamId = await storage.read(key: 'teamId');
    var projectStartDate = await storage.read(key: 'projectStartDate');
    var projectType = await storage.read(key: 'projectType');
    String? studentRollNo = await storage.read(key: 'studentRollNo');

    if (teamId != null) {
      try {
        var response = await http.get(
            Uri.parse('http://192.168.0.161:4000/api/team/getTeam/$teamId'));
        var data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          for (var member in data[0]['teamMembers']) {
            teamMembers.add(member.toString());
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch team members : ${e.toString()}'),
            ),
          );
        }
      }
    }

    fetchTaskStatus(studentRollNo, projectId);

    setState(() {
      this.projectId = projectId;
      this.projectTitle = projectTitle;
      this.projectDescription = projectDescription;
      this.projectStatus = projectStatus;
      this.projectDomain = projectDomain;
      this.teamId = teamId;
      this.projectStartDate = projectStartDate;
      this.projectType = projectType;
      _isLoading = false;
    });
  }

  void addTask() async {
    const storage = FlutterSecureStorage();
    String? studentRollNo = await storage.read(key: 'studentRollNo');
    try {
      var response = await http.post(
        Uri.parse('http://192.168.0.161:4000/api/task/addTask'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'taskName': taskNameController.text,
          'taskDescription': taskDescriptionController.text,
          'projectId': projectId,
          'studentRollNo': studentRollNo
        }),
      );
      if (response.statusCode == 200) {
        taskNameController.clear();
        taskDescriptionController.clear();
        fetchTaskStatus(studentRollNo, projectId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully'),
              backgroundColor: Color.fromARGB(255, 59, 180, 63),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add task : ${response.body}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add task : ${e.toString()}'),
          ),
        );
      }
    }
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                            // _buildTableRow('Start Date', projectStartDate),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SfCircularChart(
                          title: const ChartTitle(text: 'Tasks Status'),
                          legend: const Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap,
                            position: LegendPosition.bottom,
                          ),
                          series: <PieSeries<_ChartData, String>>[
                            PieSeries<_ChartData, String>(
                              dataSource: [
                                _ChartData('Completed Tasks', completedTasks),
                                _ChartData('Pending Tasks', pendingTasks),
                              ],
                              xValueMapper: (_ChartData data, _) => data.label,
                              yValueMapper: (_ChartData data, _) => data.value,
                              dataLabelMapper: (_ChartData data, _) =>
                                  '${data.label} : ${data.value}',
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Task',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: taskNameController,
                          decoration: const InputDecoration(
                            labelText: 'Task Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: taskDescriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Task Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            addTask();
                            Navigator.pop(context);
                          },
                          child: const Text('Add Task'),
                        ),
                      ],
                    ),
                  );
                });
          },
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.task_sharp),
              label: 'Tasks',
            ),
            if (projectType == 'Academic')
              const BottomNavigationBarItem(
                icon: Icon(Icons.flag_circle_rounded),
                label: 'Milestones',
              ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.code_rounded),
              label: 'Github',
            ),
          ],
          onTap: (index) {},
        ));
  }

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
