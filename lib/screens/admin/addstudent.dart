import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Addstudent extends StatefulWidget {
  const Addstudent({super.key});

  @override
  State<Addstudent> createState() => _AddstudentState();
}

class _AddstudentState extends State<Addstudent> {
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentRollNoController =
      TextEditingController();
  final TextEditingController _studentBranchController =
      TextEditingController();
  final TextEditingController _studentYearController = TextEditingController();
  final TextEditingController _studentSectionController =
      TextEditingController();
  final TextEditingController _studentSemesterController =
      TextEditingController();
  final TextEditingController _studentEmailController = TextEditingController();
  final TextEditingController _studentPasswordController =
      TextEditingController();
  final TextEditingController _studentUsernameController =
      TextEditingController();

  void addStudent() async {
    try {
      var response = await http.post(
          Uri.parse(
              '${dotenv.env['API_KEY']}/api/user/addUser'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': _studentEmailController.text,
            'password': _studentPasswordController.text,
            'username': _studentUsernameController.text,
            'studentYear': _studentYearController.text,
            'studentBranch': _studentBranchController.text,
            'studentSection': _studentSectionController.text,
            'studentRollNo': _studentRollNoController.text,
            'studentSemester': _studentSemesterController.text,
            'studentName': _studentNameController.text,
          }));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Student added successfully',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ));
        }
        setState(() {
          _studentNameController.clear();
          _studentRollNoController.clear();
          _studentBranchController.clear();
          _studentYearController.clear();
          _studentSectionController.clear();
          _studentSemesterController.clear();
          _studentEmailController.clear();
          _studentPasswordController.clear();
          _studentUsernameController.clear();
        });
      } 
      else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Error adding student : ${response.body}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Error adding student : $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _studentEmailController,
                decoration: const InputDecoration(
                  labelText: 'Student Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Student Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentUsernameController,
                decoration: const InputDecoration(
                  labelText: 'Student Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentNameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentRollNoController,
                decoration: const InputDecoration(
                  labelText: 'Student Roll No',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentBranchController,
                decoration: const InputDecoration(
                  labelText: 'Student Branch',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Student Year',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentSectionController,
                decoration: const InputDecoration(
                  labelText: 'Student Section',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentSemesterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Student Semester',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  addStudent();
                },
                child: const Text('Add Student'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
