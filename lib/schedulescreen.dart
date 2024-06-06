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
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<ScheduleModel>> _schedules;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    print ('loading schedule now...');
    setState(() {
      _schedules = _databaseHelper.getSchedules();
    });
    _schedules.then((schedules) {
      print('Loaded schedules: $schedules'); // Debug log
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedules")),
      body: FutureBuilder<List<ScheduleModel>>(
        future: _schedules,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Schedules found!'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          else {
            final schedules = snapshot.data!;
            return ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(schedules[index].name),
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
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _databaseHelper.deleteSchedule(schedules[index].id);
                      _loadSchedules();
                    },
                  ),
                );
              },
            );
          }
        },
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
                      await _databaseHelper.createSchedule(_controller.text);
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
