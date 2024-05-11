import 'package:flutter/material.dart';
import 'package:schedule_builder/schedule.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //const ({super.key});
  List<String> schedules = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Page'),
        actions: [
          IconButton(
            onPressed: () {
              // Add a new HomeScreen to the list
              setState(() {
                schedules.add('Schedule ${schedules.length + 1}');
              });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(schedules[index]),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          );
        },
      ),
    );
  }
}
