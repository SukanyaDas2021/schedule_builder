import 'package:flutter/material.dart';
import 'package:schedule_builder/schedule.dart';
import 'package:schedule_builder/homepage.dart';

void main() {
  runApp(MyApp());
}

/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Schedule(),
      debugShowCheckedModeBanner: false,
    );
  }
}
*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: HomePage(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/home': (context) => Schedule(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => Schedule());
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
