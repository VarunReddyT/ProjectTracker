import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    var url = Uri.parse('https://ps-project-tracker.vercel.app/api/user/login');
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
        if (responseData['role'] == 'Admin') {
          const storage = FlutterSecureStorage();
          await storage.deleteAll();
          await storage.write(key: 'token', value: responseData['token']);
          await storage.write(key: 'role', value: responseData['role']);
          await storage.write(key: 'username', value: responseData['username']);
          await storage.write(key: 'email', value: responseData['email']);
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/admin");
          }
        } else {
          const storage = FlutterSecureStorage();
          await storage.deleteAll();
          await storage.write(key: 'token', value: responseData['token']);
          await storage.write(key: 'role', value: responseData['role']);
          await storage.write(
              key: 'studentName', value: responseData['studentName']);
          await storage.write(
              key: 'studentYear',
              value: responseData['studentYear'].toString());
          await storage.write(
              key: 'studentBranch', value: responseData['studentBranch']);
          await storage.write(
              key: 'studentSection', value: responseData['studentSection']);
          await storage.write(
              key: 'studentRollNo', value: responseData['studentRollNo']);
          await storage.write(
              key: 'studentSemester',
              value: responseData['studentSemester'].toString());
          await storage.write(
              key: 'inAteam', value: responseData['inAteam'].toString());
          await storage.write(key: 'teamId', value: responseData['teamId']);
          await storage.write(
              key: 'projectIds', value: jsonEncode(responseData['projectIds']));
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
