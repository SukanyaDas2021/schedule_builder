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

  final _taskController = TextEditingController();

  // AppBar title state
  bool _isEditingTitle = false;
  final TextEditingController _titleController = TextEditingController(text: "My Daily Schedule");
  int _highlightedTaskIndex = -1;

  void onCheckboxChanged(int index, bool? newValue) {
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
    });
  }

  void _addNewTask(String taskText) {
    String trimmedText = taskText.trim();
    if (trimmedText.isNotEmpty) {
      setState(() {
        tasks.add(Task(image: '', text: taskText, isDone: false));
        _taskController.clear();
        if (_highlightedTaskIndex == -1) {
          _highlightedTaskIndex = 0;
          tasks[0].isHighlighted = true;
        }
      });
    }
    else { print("Task text cannot be empty or blank."); }
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
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 90),
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
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
                        minimumSize: Size(50, 50),
                        elevation: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
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
