import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Viewteams extends StatefulWidget {
  const Viewteams({super.key});

  @override
  State<Viewteams> createState() => _ViewteamsState();
}

class _ViewteamsState extends State<Viewteams> {
  List<dynamic> teams = [];
  bool isLoading = false;
  bool isInit = true;

  void fetchTeams(int year) async {
    try {
      setState(() {
        isLoading = true;
        isInit = false;
      });
      var response = await http.get(Uri.parse(
          '${dotenv.env['API_KEY']}/api/team/getTeams/$year'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          teams.clear();
          teams.addAll(data);
          isLoading = false;
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
          title: const Text("Teams"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select Year',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('1'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('2'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('3'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('4'),
                    ),
                  ],
                  onChanged: (int? value) {
                    fetchTeams(value!);
                  },
                ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (isInit)
                const Center(
                  child: Text('Select a year to view teams'),
                )
              else
                teams.isEmpty
                ? const Center(
                    child: Text('No teams found'),
                  )
                :
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: teams.length,
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
                          teams[index]['teamName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          teams[index]['teamMembers'].join(', '),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ));
  }
}
