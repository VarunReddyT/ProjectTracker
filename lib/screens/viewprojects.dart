import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Viewprojects extends StatefulWidget {
  const Viewprojects({super.key});

  @override
  State<Viewprojects> createState() => _ViewprojectsState();
}

class _ViewprojectsState extends State<Viewprojects> {

  @override 
  void initState(){
    super.initState();
    fetchProjects();
  }
  void fetchProjects() async{
    try{
      var response = await http.get(Uri.parse('https://ps-project-tracker.vercel.app/api/project/getProjects'));
    }
    catch(e){
      if(mounted){
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to fetch projects: $e')));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
        centerTitle: true,
      ),
      // body: SingleChildScrollView(
      //   child: ,
      // )
    );
  }
}