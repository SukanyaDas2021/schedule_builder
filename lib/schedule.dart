import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:schedule_builder/taskitem.dart';
import 'package:schedule_builder/task.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  String _appBarImagePath = '';
  List<Task> tasks = [];
  bool _addingTasks = true;
  bool _checkboxClickable = false;
  bool _showTaskInput = false;

  final _taskController = TextEditingController();

  // AppBar title state
  bool _isEditingTitle = false;
  final TextEditingController _titleController = TextEditingController(text: "My Daily Schedule");
  int _highlightedTaskIndex = -1;

  bool _showThumbsUp = false;
  String? _selectedImagePath;

  void _toggleThumbsUp() {
    setState(() {
      _showThumbsUp = !_showThumbsUp;
      _checkboxClickable = false;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showThumbsUp = false;
      });
    });
  }

  void onCheckboxChanged(int index, bool? newValue) {
    if (!_checkboxClickable) return;
    setState(() {
      tasks[index].isDone = newValue ?? false;
      if (newValue ?? false) {
        _highlightedTaskIndex = (index + 1 < tasks.length) ? index + 1 : -1;
        if (_highlightedTaskIndex > -1) {
          tasks[_highlightedTaskIndex].isHighlighted = true;
          tasks[index].isHighlighted = false;
        }
        if (index == tasks.length - 1) {
          tasks[index].isHighlighted = false;
        }
      }
      if (_allTasksDone())
        _toggleThumbsUp();
    });
  }

  void _addNewTask(String taskText) {
    if (!_addingTasks) return;
    String trimmedText = taskText.trim();
    if (trimmedText.isNotEmpty) {
      setState(() {
        tasks.add(Task(image: _selectedImagePath ?? '', text: taskText, isDone: false));
        //int newIndex = tasks.length - 1;
        _taskController.clear();
        _showTaskInput = false;  // Hide the input after adding a task
        _selectedImagePath = null;
        if (_highlightedTaskIndex == -1) {
          _highlightedTaskIndex = 0;
        }
        //_pickImage();
      });
    }
    else { print("Task text cannot be empty or blank."); }
  }

  bool _allTasksDone() {
    return tasks.isNotEmpty && tasks.every((task) => task.isDone);
  }

  void _toggleAddingTasks() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure all tasks are final?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _addingTasks = false;
                  _checkboxClickable = true;
                  tasks[0].isHighlighted = true;
                  _showTaskInput = false;
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void onImageChanged(int index, String newImage) {
    setState(() {
      tasks[index].image = newImage;
    });
  }

  void onDeleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void onTextChanged(int index, String newText) {
    setState(() {
      tasks[index].text = newText;
    });
  }

  void _restartSchedule() {
    setState(() {
      // Clear all checked tasks
      tasks.forEach((task) {
        task.isDone = false;
        task.isHighlighted = false;
      });
      _addingTasks = true;
      _checkboxClickable = false;
      // Highlight the first task item
      //if (tasks.isNotEmpty) {
      //  tasks[0].isHighlighted = true;
      //}
    });
  }

  void _clearAllTasks() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to clear all tasks?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.clear(); // Clear all tasks
                  _highlightedTaskIndex = -1;
                  _addingTasks = true;
                  _checkboxClickable = false;
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAppBarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _appBarImagePath = pickedFile.path;
      });
    }
  }

  void _toggleTaskInput() {
    setState(() {
      _showTaskInput = !_showTaskInput;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          if (tasks.isEmpty)
            Center(
              child: Text(
                'No tasks in schedule!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.fromLTRB(2, 2, 2, _addingTasks ? 120 : 5),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  //bool isNextTask = index < tasks.length - 1;
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TaskItem(
                      image: tasks[index].image,
                      text: tasks[index].text,
                      isDone: tasks[index].isDone,
                      onCheckboxChanged: (newValue) => onCheckboxChanged(index, newValue),
                      onImageChanged: (newImage) => onImageChanged(index, newImage),
                      onDelete: () => onDeleteTask(index),
                      onTextChanged: (newText) => onTextChanged(index, newText),
                      isHighlighted: tasks[index].isHighlighted,
                    ),
                  );
                },
              ),
            ),
          if (_showTaskInput)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: 8.0),
                            height: 80,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0, 0),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: _taskController,
                              decoration: InputDecoration(
                                hintText: 'Enter task',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8), // Add some space between text field and buttons
                        ElevatedButton(
                          onPressed: () {
                            _addNewTask(_taskController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size(50, 80),
                            elevation: 10,
                          ),
                          child: Text(
                            '+',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // Add some space between text field and buttons
                    ElevatedButton(
                      onPressed: () {
                        _pickImage(); // Replace _pickImage with your image picking logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size(120, 40),
                        elevation: 10,
                      ),
                      child: Text(
                        'Add Image',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10), // Add some space between buttons
                  ],
                ),
              ),
            ),
          if (!_showTaskInput)
            Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: _addingTasks,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0,5,20,20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _toggleTaskInput,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: Size(140, 50),
                          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        child: Text('Add task'),
                      ),
                      ElevatedButton(
                        onPressed: _toggleAddingTasks,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: Size(140, 50),
                          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        child: Text('Click when done'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Visibility(
            visible: _showThumbsUp,
            child: Center(
              child: AnimatedOpacity(
                opacity: _showThumbsUp ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                child: Image.asset(
                  'assets/thumbsup.png',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ),
          _allTasksDone()
              ? Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _restartSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(140, 40),
                      textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Restart Schedule'),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: _clearAllTasks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: Size(140, 40),
                      textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Clear All Tasks'),
                  ),
                ],
              ),
            ),
          )
              : SizedBox(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.purple[100],
      centerTitle: true,
      title: _isEditingTitle
          ? Center(
        child: TextField(
          controller: _titleController,
          autofocus: true,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.teal[900]),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Edit title',
          ),
          onSubmitted: (newTitle) {
            setState(() {
              _isEditingTitle = false;
            });
          },
        ),
      )
          : GestureDetector(
        onTap: () {
          setState(() {
            _isEditingTitle = true;
          });
        },
        child: Center(
          child: Text(
            _titleController.text,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.teal[900]),
          ),
        ),
      ),
      actions: [
        SizedBox(width: 10),
        GestureDetector(
          onTap: _pickAppBarImage,
          child: Container(
            height: 60,
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _appBarImagePath.isNotEmpty
                  ? Image.file(
                File(_appBarImagePath),
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/blank_image.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
