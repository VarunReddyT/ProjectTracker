import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Addacademicproject extends StatefulWidget {
  const Addacademicproject({super.key});

  @override
  State<Addacademicproject> createState() => _AddacademicprojectState();
}

class _AddacademicprojectState extends State<Addacademicproject> {
  TextEditingController projectTitle = TextEditingController();
  TextEditingController projectDescription = TextEditingController();
  TextEditingController projectDomain = TextEditingController();
  TextEditingController projectTechnologies = TextEditingController();

  List<String> technologies = [];
  void _addTechnology() {
    if (projectTechnologies.text.isNotEmpty) {
      setState(() {
        technologies.add(projectTechnologies.text);
        projectTechnologies.clear();
      });
    }
  }

  void _submitForm() async {
    try {
      var response = await http.post(
          Uri.parse('http://192.168.0.161:4000/api/project/addProject'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'projectTitle': projectTitle.text,
            'projectDescription': projectDescription.text,
            'projectDomain': projectDomain.text,
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
          projectTitle.clear();
          projectDescription.clear();
          projectDomain.clear();
          projectTechnologies.clear();
          technologies.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Failed to add project',
            style: TextStyle(color: Colors.redAccent),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Academic Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: projectTitle,
                decoration: const InputDecoration(
                  labelText: 'Project Title',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: projectDescription,
                decoration: const InputDecoration(
                  labelText: 'Project Description',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: projectDomain,
                decoration: const InputDecoration(
                  labelText: 'Project Domain',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: projectTechnologies,
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
    );
  }
}
