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

  void fetchMilestones() async {
    const storage = FlutterSecureStorage();
    var projectId = await storage.read(key: 'currentProjectId');
    try{
      var response = await http.get(Uri.parse('https://ps-project-tracker.vercel.app/api/milestone/getMilestone/$projectId'));
      if(response.statusCode == 200){
        var data = jsonDecode(response.body);
        setState(() {
          milestones.clear();
          milestones.addAll(data);
        });
      }
      else{
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch milestones')));
        }
      }
    }
    catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch milestones: $e')));
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}