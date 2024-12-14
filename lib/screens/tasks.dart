import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  @override
  void initState() {
    super.initState();
    getTasks();
  }

  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskDescriptionController = TextEditingController();

  List<dynamic> tasks = [];
  bool isLoading = true;
  int? expandedTaskIndex;

  void getTasks() async {
    try {
      const storage = FlutterSecureStorage();
      var studentRollNo = await storage.read(key: 'studentRollNo');
      var projectId = await storage.read(key: 'projectId');
      var response = await http.get(
        Uri.parse(
            'http://192.168.0.161:4000/api/task/getTasks/$studentRollNo/$projectId'),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            tasks = data;
            isLoading = false; // Stop loading indicator
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false; // Stop loading indicator
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching tasks: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false; // Stop loading indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching tasks: $e'),
          ),
        );
      }
    }
  }

  void addTask() async {
    const storage = FlutterSecureStorage();
    String? studentRollNo = await storage.read(key: 'studentRollNo');
    String? projectId = await storage.read(key: 'projectId');
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
        getTasks();
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

  void markTaskAsCompleted(String taskId) async {
    try {
      var response = await http.put(
        Uri.parse('http://192.168.0.161:4000/api/task/updateTaskStatus/$taskId'),
      );
      if (response.statusCode == 200) {
        getTasks();
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task marked as completed!'),
            ),
          );
        }
      } else {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing task: ${response.statusCode}'),
            ),
          );
        }
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing task: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(
                  child: Text(
                    'No tasks available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    final isExpanded = expandedTaskIndex == index;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              task['taskName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Status: ${task['taskStatus'] == true ? 'Completed' : 'Pending'}",
                              style: TextStyle(
                                color: task['taskStatus'] == true
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isExpanded) {
                                    expandedTaskIndex = null;
                                  } else {
                                    expandedTaskIndex = index;
                                  }
                                });
                              },
                            ),
                          ),
                          if (isExpanded) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Description: ${task['taskDescription']}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  if(task['taskStatus'] == false) 
                                    ElevatedButton(
                                      onPressed: () => markTaskAsCompleted(task['_id']),
                                      child: const Text('Mark as Completed'),
                                    ),
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  },
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
    );
  }
}
