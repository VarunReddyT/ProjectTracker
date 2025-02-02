import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Viewmilestones extends StatefulWidget {
  const Viewmilestones({super.key});

  @override
  State<Viewmilestones> createState() => _ViewmilestonesState();
}

class _ViewmilestonesState extends State<Viewmilestones> {
  @override
  void initState() {
    super.initState();
    fetchMilestones();
  }

  List<dynamic> milestones = [];
  String? projectTitle;

  void fetchMilestones() async {
    const storage = FlutterSecureStorage();
    var projectId = await storage.read(key: 'currentProjectId');
    var title = await storage.read(key: 'currentProjectTitle');
    setState(() {
      projectTitle = title;
    });
    try {
      var response = await http.get(Uri.parse(
          'https://ps-project-tracker.vercel.app/api/milestone/getMilestone/$projectId'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          milestones.clear();
          milestones.addAll(data);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to fetch milestones')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch milestones: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(projectTitle ?? 'Milestones', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          milestones.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
              )
              : Column(
                  children: milestones.map((milestone) {
                    return Card(
                      child: ListTile(
                        title: Text(milestone['milestoneName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0)),
                        subtitle: Text(milestone['milestoneDescription'],
                            style: const TextStyle(fontSize: 12.0)),
                        trailing: Text(
                            milestone['milestoneEndDate'].substring(0, 10),
                            style: TextStyle(
                                color: DateTime.now().isAfter(DateTime.parse(
                                        milestone['milestoneEndDate']))
                                    ? Colors.red
                                    : Colors.green)),
                      ),
                    );
                  }).toList(),
                )
        ])));
  }
}
