import 'package:flutter/material.dart';

class Addteam extends StatefulWidget {
  const Addteam({super.key});

  @override
  State<Addteam> createState() => _AddteamState();
}

class _AddteamState extends State<Addteam> {

  List<String> _teamMembers = <String>[];

  TextEditingController _teamNameController = TextEditingController();
  TextEditingController _teamMembersController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        title: const Text('Add Team'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _teamMembersController,
                decoration: const InputDecoration(
                  labelText: 'Team Members',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _teamMembers.add(_teamMembersController.text);
                  _teamMembersController.clear();
                });
              },
              child: const Icon(Icons.add),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _teamMembers.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_teamMembers[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _teamMembers.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}