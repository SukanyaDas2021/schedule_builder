import 'package:flutter/material.dart';
import 'package:schedule_builder/schedulescreen.dart';
import 'package:schedule_builder/taskscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: Schedule(),
      //home: SchedulesScreen(),
      debugShowCheckedModeBanner: false,
      home: BottomNavBarScreen(),
    );
  }
}

class BottomNavBarScreen extends StatefulWidget {
  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;

  // List of screens to switch between
  final List<Widget> _screens = [
    SchedulesScreen(), // Replace with your ScheduleScreen widget
    TaskScreen(), // Replace with your TaskScreen widget
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.05;
    double selectedFontSize = screenWidth * 0.03;
    double unselectedFontSize = screenWidth * 0.03;
    return Scaffold(
      body: _screens[_selectedIndex], // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[900], // Optional: customize the selected icon color
        unselectedItemColor: Colors.black, // Optional: customize the unselected icon color
        iconSize: iconSize, //30, // Increase the size of the icons
        selectedFontSize: selectedFontSize, // Increase the font size of the selected text
        unselectedFontSize: unselectedFontSize,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}