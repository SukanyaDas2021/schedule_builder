import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:schedule_builder/taskitem.dart';
import 'package:schedule_builder/task.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _appBarImagePath = '';
  List<Task> tasks = [];
  bool _addingTasks = true;
  bool _checkboxClickable = false;

  final _taskController = TextEditingController();

  // AppBar title state
  bool _isEditingTitle = false;
  final TextEditingController _titleController = TextEditingController(text: "My Daily Schedule");
  int _highlightedTaskIndex = -1;

  bool _showThumbsUp = false;
  void _toggleThumbsUp() {
    setState(() {
      _showThumbsUp = !_showThumbsUp;
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
      if (_allTasksDone())  _toggleThumbsUp();
    });
  }

  void _addNewTask(String taskText) {
    if (!_addingTasks) return;
    String trimmedText = taskText.trim();
    if (trimmedText.isNotEmpty) {
      setState(() {
        tasks.add(Task(image: '', text: taskText, isDone: false));
        _taskController.clear();
        if (_highlightedTaskIndex == -1) {
          _highlightedTaskIndex = 0;
        }
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

  Future<void> _pickAppBarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _appBarImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(2, 2, 2, _addingTasks ? 90 : 5),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  bool isNextTask = index < tasks.length - 1;
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
            Visibility(
                visible: _addingTasks,
                child: Container(
                  margin: EdgeInsets.only(bottom: 35),
                  alignment: Alignment.bottomCenter,
                  child:
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
                          height: 50,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            boxShadow: const [BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0,0),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              hintText: 'Add new task',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20, right: 20),
                        child: ElevatedButton(
                          child: Text('+', style: TextStyle(color: Colors.white,fontSize: 30),),
                          onPressed: () {
                            _addNewTask(_taskController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            minimumSize: Size(30, 30),
                            elevation: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Visibility(
                visible: _addingTasks,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20,4,20,2),
                    child: ElevatedButton(
                      onPressed: _toggleAddingTasks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Background color
                        foregroundColor: Colors.white, // Text color
                        minimumSize: Size(double.infinity, 40), // Stretch the button horizontally
                        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), // Text style
                      ),
                      child: Text('Click when done!'),
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
                      'assets/thumbsup.png', // Replace 'thumbs_up_cartoon.png' with the actual file name of your image asset
                      width: 200, // Adjust the width of the image as needed
                      height: 200,
                  ),
                ),
              ),
            ),
            _allTasksDone()
                ?
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Implement restart schedule logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          // Background color
                          foregroundColor:
                          Colors.white,
                          // Text color
                          minimumSize: Size(140, 30),
                          // Set the size of the button
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold), // Text style
                        ),
                        child: Text('Restart Schedule'),
                      ),
                      SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          // Implement clear all tasks logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Background color
                          foregroundColor:
                          Colors.white, // Text color
                          minimumSize: Size(
                              140, 30), // Set the size of the button
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold), // Text style
                        ),
                        child: Text('Clear All Tasks'),
                      ),
                    ],
                  ),
                ),
              )
                  : SizedBox()          ]
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal[200],
      centerTitle: true,
      title: _isEditingTitle ?
        Center(
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
