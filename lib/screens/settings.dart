import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Replace with shared_preferences
import 'package:http/http.dart' as http;
import 'dart:convert';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController currentPassword = TextEditingController();

  void changePassword() async {
    try {
      final prefs = await SharedPreferences.getInstance(); // Use SharedPreferences
      var email = prefs.getString('email'); // Read email from SharedPreferences

      if (email == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not found. Please log in again.'),
            ),
          );
        }
        return;
      }

      var response = await http.post(
        Uri.parse('https://ps-project-tracker.vercel.app/api/user/changePassword'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'currentPassword': currentPassword.text,
          'newPassword': newPassword.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          newPassword.clear();
          confirmPassword.clear();
          currentPassword.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred : ${response.body}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred : $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: currentPassword,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: newPassword,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: confirmPassword,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPassword.text == confirmPassword.text) {
                changePassword(); // Call the changePassword method
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                  ),
                );
              }
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }
}