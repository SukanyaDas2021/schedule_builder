import 'package:flutter/material.dart';
import 'package:schedule_builder/schedulescreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: Schedule(),
      home: SchedulesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
