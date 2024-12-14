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
          // actions: [
          //   PopupMenuButton<String>(
          //     onSelected: (value) {
          //       if (value == 'Delete Project') {
          //         showDialog(
          //           context: context,
          //           builder: (BuildContext context) {
          //             return AlertDialog(
          //               title: const Text('Delete Project'),
          //               content: const Text(
          //                   'Are you sure you want to delete this project?'),
          //               actions: [
          //                 TextButton(
          //                   onPressed: () {
          //                     Navigator.pop(context);
          //                   },
          //                   child: const Text('Cancel'),
          //                 ),
          //                 TextButton(
          //                   onPressed: () {
          //                     Navigator.pop(context);
          //                     Navigator.pushNamed(context, '/home');
          //                   },
          //                   child: const Text('Delete'),
          //                 ),
          //               ],
          //             );
          //           },
          //         );
          //       }
          //     },
          //     itemBuilder: (BuildContext context) {
          //       return const <PopupMenuEntry<String>>[
          //         PopupMenuItem<String>(
          //           value: 'Delete Project',
          //           child: Text('Delete Project',
          //           style: TextStyle(
          //             color: Colors.red,
          //           ),
          //           ),

          //         ),
          //       ];
          //     },
          //   )
          // ],
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
                        if (completedTasks + pendingTasks > 0)
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
                                    '${data.value}',
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                ),
                              )
                            ],
                          )
                        else
                          const Center(
                            child: Text(
                              'No tasks available',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: ExpandableFab(),
    );
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

class ExpandableFab extends StatefulWidget {
  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildIcon(Offset(90, -20), Icons.flag_outlined, 0),
        _buildIcon(Offset(60, 60), Icons.task_outlined, 1),
        // _buildIcon(Offset(-20,100), Icons.code_outlined, 2),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: toggle,
            child: Icon(_isOpen ? Icons.close : Icons.more_horiz_outlined),
          ),
        ),
      ],
    );
  }

  // Method to create icons in specific positions
  Widget _buildIcon(Offset offset, IconData icon, int index) {
    return Positioned(
      bottom: 20 + offset.dy,
      right: 20 + offset.dx,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Visibility(
          visible: _isOpen,
          child: FloatingActionButton(
            onPressed: () {
              if (index == 0) {
                Navigator.pushNamed(context, '/milestones');
              } else if (index == 1) {
                Navigator.pushNamed(context, '/tasks');
              } 
              // else {
              //   Navigator.pushNamed(context, '/settings');
              // }
            },
            child: Icon(icon),
          ),
        ),
      ),
    );
  }
}