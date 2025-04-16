import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Addteam extends StatefulWidget {
  const Addteam({super.key});

  @override
  State<Addteam> createState() => _AddteamState();
}

class _AddteamState extends State<Addteam> {
  final TextEditingController _teamNameController = TextEditingController();
  int? studentsYear;
  List<dynamic> _availableStudents = [];
  List<String> _selectedStudents = [];
  bool _isLoading = false;

  Future<void> _fetchUnassignedStudents() async {
    if (studentsYear == null) return;

    setState(() {
      _isLoading = true;
      _availableStudents = [];
    });

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_KEY']}/api/team/getNotInATeamStudents/$studentsYear'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _availableStudents = json.decode(response.body);
        });
      } else {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch students: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching students: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleStudentSelection(String rollNumber) {
    setState(() {
      if (_selectedStudents.contains(rollNumber)) {
        _selectedStudents.remove(rollNumber);
      } else {
        if (_selectedStudents.length < 6) {
          _selectedStudents.add(rollNumber);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 6 team members allowed')),
          );
        }
      }
    });
  }

  void addTeam() async {
    if (_teamNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a team name')),
      );
      return;
    }

    if (studentsYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a year')),
      );
      return;
    }

    if (_selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one team member')),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('${dotenv.env['API_KEY']}/api/team/addTeam'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'teamName': _teamNameController.text,
          'teamMembers': _selectedStudents,
          'studentsYear': studentsYear,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Team added successfully', style: TextStyle(color: Colors.green)),
          ));
          setState(() {
            _teamNameController.clear();
            _selectedStudents.clear();
            studentsYear = null;
            _availableStudents.clear();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add team: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add team: $e')),
        );
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Select Year',
                border: OutlineInputBorder(),
              ),
              value: studentsYear,
              onChanged: (int? value) {
                setState(() {
                  studentsYear = value;
                  _selectedStudents.clear();
                });
                _fetchUnassignedStudents();
              },
              items: const [
                DropdownMenuItem(value: 1, child: Text('First Year')),
                DropdownMenuItem(value: 2, child: Text('Second Year')),
                DropdownMenuItem(value: 3, child: Text('Third Year')),
                DropdownMenuItem(value: 4, child: Text('Fourth Year')),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_availableStudents.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Students:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Selected: ${_selectedStudents.length}/6'),
                  const SizedBox(height: 10),
                  ..._availableStudents.map((student) {
                    final isSelected = _selectedStudents.contains(student['studentRollNo']);
                    return CheckboxListTile(
                      title: Text('${student['studentName']} (${student['studentRollNo']})'),
                      value: isSelected,
                      onChanged: (bool? value) {
                        _toggleStudentSelection(student['studentRollNo']);
                      },
                    );
                  }).toList(),
                ],
              )
            else if (studentsYear != null)
              const Text('No unassigned students available for this year'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addTeam,
              child: const Text('Create Team'),
            ),
          ],
        ),
      ),
    );
  }
}