import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>(); // To handle form validation
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _techController = TextEditingController();

  List<String> technologies = [];

  void _addTechnology() {
    if (_techController.text.isNotEmpty) {
      setState(() {
        technologies.add(_techController.text);
        _techController.clear();
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        const storage = FlutterSecureStorage();
        var studentRollNo = await storage.read(key: 'studentRollNo');
        var response = await http.post(
            Uri.parse(
                'http://192.168.0.163:4000/api/project/addPersonalProject/$studentRollNo'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'projectTitle': _projectNameController.text,
              'projectDescription': _descController.text,
              'projectDomain': _domainController.text,
              'projectTechnologies': technologies,
            }));
        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'Project added successfully',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ));
          }
          setState(() {
            _projectNameController.clear();
            _descController.clear();
            _domainController.clear();
            _techController.clear();
            technologies.clear();
          });
          if(mounted){
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'Failed to add project',
                style: TextStyle(color: Colors.redAccent),
              ),
            ));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add project : $e'),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Project"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                TextFormField(
                  controller: _projectNameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _domainController,
                  decoration: const InputDecoration(
                    labelText: 'Domain',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a domain';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _techController,
                        decoration: const InputDecoration(
                          labelText: 'Technology',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addTechnology,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  children: technologies
                      .map((tech) => Chip(
                            label: Text(tech),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                technologies.remove(tech);
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
