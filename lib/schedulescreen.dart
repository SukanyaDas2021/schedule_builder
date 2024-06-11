import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:schedule_builder/database_helper.dart';
import 'package:schedule_builder/schedulemodel.dart';
import 'package:schedule_builder/schedule.dart';

class SchedulesScreen extends StatefulWidget {
  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  final DatabaseHelper _databaseHelperScheduleScreen = DatabaseHelper();
  Future<List<ScheduleModel>>? _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = Future.value([]);
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    print ('loading schedule now...');
    final schedules = await _databaseHelperScheduleScreen.getSchedules();
    setState(() {
      _schedules = Future.value(schedules);
    });
    print('Loaded schedules: $schedules');
    for (var schedule in schedules) {
      print('Schedule ID: ${schedule.id}, Name: ${schedule.name}, Adding Tasks: ${schedule.addingTasks}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlue[50],
        shadowColor: Colors.lightGreen,
        surfaceTintColor: Colors.lime,
        elevation: 0,
        title: Text(
            "Schedules",
          style: TextStyle(
            fontFamily: 'RobotoMono', // Specify the font family
            fontWeight: FontWeight.w700, // Set font weight
            fontStyle: FontStyle.normal, // Add italic style
            fontSize: 24, // Increase font size
            color: Colors.blue[900], // Change text color
            shadows: [ // Add text shadows
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2.0, 2.0),
              ),
            ],
            letterSpacing: 2.0, // Increase letter spacing for a more spaced look
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue.shade50, Colors.cyanAccent.shade100],
          ),
        ),
        child: FutureBuilder<List<ScheduleModel>>(
          future: _schedules,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              _databaseHelperScheduleScreen.removeDatabase('schedule');
              return Center(child: Text('No Schedules found!'));
            }
            else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            else {
              final schedules = snapshot.data!;
              return ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.lightGreen.shade100, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        schedules[index].name,
                        style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [Colors.purple, Colors.blue],
                            ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ),
                      tileColor: Colors.transparent,
                      hoverColor: Colors.blueAccent.withOpacity(0.2),
                      contentPadding: EdgeInsets.fromLTRB(20, 8, 2, 5),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Schedule(schedule: schedules[index]),
                          ),
                        );
                        _loadSchedules();
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.blueGrey),
                        alignment: Alignment.bottomRight,
                        onPressed: () async {
                          await _databaseHelperScheduleScreen.deleteSchedule(schedules[index].id);
                          await _databaseHelperScheduleScreen.deleteAppBar(schedules[index].id);
                          _loadSchedules();
                        },
                      ),
                    ),
                  );
                },
              );

            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final TextEditingController _controller = TextEditingController();
              return AlertDialog(
                title: Text("Create Schedule"),
                content: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "Schedule Name"),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      int scheduleId = await _databaseHelperScheduleScreen.createSchedule(_controller.text);
                      Navigator.pop(context);
                      _loadSchedules();
                    },
                    child: Text("Create"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
