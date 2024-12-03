import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';   

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> _list = ['Home', 'Profile', 'Settings', 'Logout'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: GFDrawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const GFDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Icon(
                    Icons.account_circle,
                    size: 100,
                  ),
                ),
              ),
            ),         
            ListTile(
              title: const Text('Profile'),
              trailing : const Icon(
                Icons.account_circle_rounded,
              ),
              onTap: () {
                // Add functionality here if needed
              },
            ),
            ListTile(
              title: const Text('Settings'),
              trailing: const Icon(
                Icons.settings,
              ),
              onTap: () {
                // Add functionality here if needed
              },
            ),
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              onTap: () {
                // Add functionality here if needed
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: _list.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_list[index]),
                  onTap: () {
                    // Add functionality here if needed
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
