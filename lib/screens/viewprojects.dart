import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Viewprojects extends StatefulWidget {
  const Viewprojects({super.key});

  @override
  State<Viewprojects> createState() => _ViewprojectsState();
}

class _ViewprojectsState extends State<Viewprojects> {
  List<dynamic> projects = [];
  void fetchProjects(int year) async {
    try {
      var response = await http.get(Uri.parse(
          'https://ps-project-tracker.vercel.app/api/project/getProjects/$year'));
          if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.body)));
          }
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
    }
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
            DropdownButtonFormField<int>(
              items: [1, 2, 3, 4].map((int year) {
                return DropdownMenuItem<int>(value: year, child: Text('$year'));
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
            projects.isEmpty
                ? const Center(child : Text('Select a year to view projects'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(projects[index]['projectTitle']),
                        subtitle: Text(projects[index]['projectDescription']),
                      );
                    },
                  ),
          ],
        )));
  }
}
