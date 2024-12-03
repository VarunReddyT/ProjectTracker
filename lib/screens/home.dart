import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';   

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: GFDrawer( // Add the GFDrawer here
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const GFDrawerHeader(
              currentAccountPicture: GFAvatar(
                radius: 80.0,
                backgroundImage: NetworkImage(
                    "https://cdn.pixabay.com/photo/2017/12/03/18/04/christmas-balls-2995437_960_720.jpg"),
              ),
              otherAccountsPictures: <Widget>[
                Image(
                  image: NetworkImage(
                      "https://cdn.pixabay.com/photo/2019/12/20/00/03/road-4707345_960_720.jpg"),
                  fit: BoxFit.cover,
                ),
                GFAvatar(
                  child: Text("ab"),
                )
              ],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:   <Widget>[
                  Text('User Name'),
                  Text('user@userid.com'),
                ],
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Add functionality here if needed
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Add functionality here if needed
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome to Home Page'),
      ),
    );
  }
}
