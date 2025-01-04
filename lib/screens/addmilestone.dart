import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void fetchProjects(int year) async {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch projects : $e")));
      }
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

  void showMilestoneModal(int projectId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add milestone'),
            content: Column(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _milestoneName,
                    decoration: const InputDecoration(
                      labelText: 'Milestone Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextFormField(
                    controller: _milestoneDescription,
                    decoration: const InputDecoration(
                      labelText: 'Milestone Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _milestoneStartDate,
                  readOnly: true,
                  onTap: () {
                    _pickDate(_milestoneStartDate);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _milestoneEndDate,
                  readOnly: true,
                  onTap: () {
                    _pickDate(_milestoneEndDate);
                  },
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height : 16),
                ElevatedButton(
                  onPressed: (){
                    
                  }, 
                  child: const Text('Add milestone'))
              ],
            ),
          );
        });
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
              projects.isEmpty
                  ? const Text('No projects available')
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
                              showMilestoneModal(projects[index]['_id']);
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
