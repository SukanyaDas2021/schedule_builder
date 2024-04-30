import 'package:flutter/material.dart';
import 'package:schedule_builder/homescreen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //const ({super.key});
  List<String> homeScreens = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              // Add a new HomeScreen to the list
              setState(() {
                homeScreens.add('Home Screen ${homeScreens.length + 1}');
              });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: homeScreens.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(homeScreens[index]),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          );
        },
      ),
    );
  }
}
