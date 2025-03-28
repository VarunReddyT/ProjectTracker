import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Addteam extends StatefulWidget {
  const Addteam({super.key});

  @override
  State<Addteam> createState() => _AddteamState();
}

class _AddteamState extends State<Addteam> {
  final List<String> _teamMembers = <String>[];

  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamMembersController = TextEditingController();
  int? studentsYear;
  void addTeam() async {
    try {
      var response = await http.post(
          Uri.parse('https://ps-project-tracker.vercel.app/api/team/addTeam'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'teamName': _teamNameController.text,
            'teamMembers': _teamMembers,
            'studentsYear': studentsYear,
          }));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Team added successfully',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ));
        }
        setState(() {
          _teamNameController.clear();
          _teamMembers.clear();
          studentsYear = null;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add team')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add team: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Team'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Select Year',
                    border: OutlineInputBorder(),
                  ),
                  value: studentsYear,
                  onChanged: (int? value) {
                    setState(() {
                      studentsYear = value;
                    });
                  },
                  items: <int>[1, 2, 3, 4].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _teamMembersController,
                        decoration: const InputDecoration(
                          labelText: 'Team Members',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_teamMembersController.text.isNotEmpty) {
                          setState(() {
                            _teamMembers
                                .add(_teamMembersController.text.toUpperCase());
                            _teamMembersController.clear();
                          });
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _teamMembers
                    .map((member) => Chip(
                          label: Text(member),
                          deleteIcon:
                              const Icon(Icons.remove, color: Colors.red),
                          onDeleted: () {
                            setState(() {
                              _teamMembers.remove(member);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  addTeam();
                },
                child: const Text('Add Team'),
              ),
            ],
          ),
        ),
    );
  }
}
