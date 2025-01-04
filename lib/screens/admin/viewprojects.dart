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
  bool isLoading = false;
  bool isInit = true;
  void fetchProjects(int year) async {
    setState(() {
      isLoading = true;
      isInit = false;
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
                                // Add your onTap functionality here
                              },
                            ),
                          );
                        },
                      ),
          ],
        )));
  }
}
