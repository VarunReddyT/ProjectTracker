import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields'),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse('${dotenv.env['API_KEY']}/api/user/login');
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        if (responseData['role'] == 'Admin') {
          await prefs.clear(); // Clear all stored data
          await prefs.setString('token', responseData['token']);
          await prefs.setString('role', responseData['role']);
          await prefs.setString('username', responseData['username']);
          await prefs.setString('email', responseData['email']);
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/admin");
          }
        } else {
          await prefs.clear(); // Clear all stored data
          await prefs.setString('token', responseData['token']);
          await prefs.setString('studentId',responseData['id']);
          await prefs.setString('role', responseData['role']);
          await prefs.setString('studentName', responseData['studentName']);
          await prefs.setInt(
              'studentYear', responseData['studentYear']);
          await prefs.setString('studentBranch', responseData['studentBranch']);
          await prefs.setString(
              'studentSection', responseData['studentSection']);
          await prefs.setString('studentRollNo', responseData['studentRollNo']);
          await prefs.setInt(
              'studentSemester', responseData['studentSemester']);
          await prefs.setBool('inAteam', responseData['inAteam']);
          await prefs.setString('teamId', responseData['teamId']);
          await prefs.setString(
              'projectIds', jsonEncode(responseData['projectIds']));
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/home");
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${response.body}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
          ),
        );
      }
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.lock_outline_rounded),
                          labelText: 'Password',
                        ),
                        obscureText: true,
                      ),
                    ),
                  ],
                )),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => login(),
                    child: const Text('Login'),
                  ),
          ],
        )));
  }
}
