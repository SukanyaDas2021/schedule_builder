import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:schedule_builder/taskitem.dart';
import 'package:schedule_builder/task.dart';
import 'package:schedule_builder/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String _appBarImagePath = '';
  List<Task> tasks = [];
  bool _addingTasks = true;
  bool _checkboxClickable = false;
  bool _showTaskInput = false;
  bool _editOngoingSchedule = false;
  bool _isRecording = false;
  String? _recordedFilePath;
  FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  AudioPlayer _audioPlayer = AudioPlayer();

  final _taskController = TextEditingController();

  // AppBar title state
  bool _isEditingTitle = false;
  final TextEditingController _titleController = TextEditingController(text: "My Schedule");
  int _highlightedTaskIndex = -1;

  bool _showThumbsUp = false;
  String? _selectedImagePath;

  void _toggleThumbsUp() {
    setState(() {
      _showThumbsUp = !_showThumbsUp;
      _checkboxClickable = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showThumbsUp = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await _databaseHelper.getTasks();
    final appBarData = await _databaseHelper.getAppBarData();
    setState(() {
      tasks = loadedTasks;
      _appBarImagePath = appBarData['imagePath']!;
      _titleController.text = appBarData['title']!;
      if (tasks.isNotEmpty) {
        _highlightedTaskIndex = tasks.indexWhere((task) => task.isHighlighted);
        _checkboxClickable = !_addingTasks;
      }
    });
  }

  void onCheckboxChanged(int index, bool? newValue) {
    if (!_checkboxClickable) return;
    setState(() {
      tasks[index].isDone = newValue ?? false;
      if (newValue ?? false) {
        int nextIndex = index + 1;
        while (nextIndex < tasks.length && tasks[nextIndex].showCancelText) {
          nextIndex++;
        }
        _highlightedTaskIndex = (nextIndex < tasks.length) ? nextIndex : -1;
        if (_highlightedTaskIndex > -1) {
          tasks[_highlightedTaskIndex].isHighlighted = true;
          tasks[index].isHighlighted = false;
        }
        if (index == tasks.length - 1 || (nextIndex >= tasks.length && tasks[index].isDone)) {
          tasks[index].isHighlighted = false;
        }
      }
      if (_allTasksDone()) {
        _toggleThumbsUp();
      }
    });
  }

  void _addNewTask(String taskText) {
    if (!_addingTasks) return;
    String trimmedText = taskText.trim();
    if (trimmedText.isNotEmpty) {
      final newTask = Task(image: _selectedImagePath ?? '', text: taskText, isDone: false);
      setState(() {
        tasks.add(newTask);
        //int newIndex = tasks.length - 1;
        _taskController.clear();
        _showTaskInput = false;  // Hide the input after adding a task
        _selectedImagePath = null;
        if (_highlightedTaskIndex == -1) {
          _highlightedTaskIndex = 0;
        }
        //_pickImage();
      });
      _databaseHelper.insertTask(newTask);
    }
    else { print("Task text cannot be empty or blank."); }
  }

  bool _allTasksDone() {
    return tasks.isNotEmpty && tasks.every((task) => task.isDone);
  }

  void _toggleAddingTasks() {
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add one or more tasks',
            style: TextStyle(fontSize: 18), // Increase the font size
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure all tasks are final?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("No"),
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
              child: const Text("Yes"),
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
    _databaseHelper.updateTask(tasks[index]);
  }

  void onDeleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _databaseHelper.deleteAllTasks(); // Clear all tasks and reinsert remaining ones
    for (var task in tasks) {
      _databaseHelper.insertTask(task);
    }
  }

  void onTextChanged(int index, String newText) {
    setState(() {
      tasks[index].text = newText;
    });
    _databaseHelper.updateTask(tasks[index]);
  }

  void _restartSchedule() {
    setState(() {
      // Clear all checked tasks
      tasks.forEach((task) {
        task.isDone = false;
        task.isHighlighted = false;
        task.showCancelText = false;
      });
      _addingTasks = true;
      _checkboxClickable = false;
      // Highlight the first task item
      //if (tasks.isNotEmpty) {
      //  tasks[0].isHighlighted = true;
      //}
    });
    _databaseHelper.deleteAllTasks();
    for (var task in tasks) {
      _databaseHelper.insertTask(task);
    }
  }

  void _clearAllTasks() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to clear all tasks?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.clear(); // Clear all tasks
                  _highlightedTaskIndex = -1;
                  _addingTasks = true;
                  _checkboxClickable = false;
                });
                _databaseHelper.deleteAllTasks();
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Clear"),
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
      _databaseHelper.updateAppBarData(_appBarImagePath, _titleController.text);
    }
  }

  void _toggleTaskInput() {
    setState(() {
      _showTaskInput = !_showTaskInput;
      _selectedImagePath = null;
      _taskController.text = '';
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

  Future<void> _showImageOptionsDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Image Options"),
          content: const Text("Would you like to edit or clear the image?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _pickAppBarImage(); // Allow the user to pick a new image
              },
              child: const Text("Edit"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _appBarImagePath = ''; // Clear the image
                });
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to edit an ongoing schedule?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _checkboxClickable = false;
                });
                _showCancelIconsForUncompletedTasks();
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showCancelIconsForUncompletedTasks() {
    setState(() {
      _editOngoingSchedule = true;
      for (var task in tasks) {
        if (!task.isDone && !task.isHighlighted) {
          task.showCancelIcon = true;
        }
      }
    });
  }

  void cancelTask(index) {
    // Handle the cancellation logic here, such as updating the state to reflect the canceled task
    setState(() {
      _checkboxClickable = false;

      tasks[index].showCancelIcon = false;
      tasks[index].isHighlighted = false;
      tasks[index].showCancelText = true;
      tasks[index].isDone = true;
    });
  }

  void ongoingScheduleUpdateSubmit() {
    setState(() {
      _checkboxClickable = true;
      _editOngoingSchedule = false;
      tasks.forEach((task) {
        task.showCancelIcon = false;
        if (task.showCancelText) {
          task.isHighlighted = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: _addingTasks ? Colors.indigo[50] : Colors.white,
      body: Stack(
        children: [
          if (tasks.isEmpty)
            const Center(
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
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TaskItem(
                      image: tasks[index].image,
                      text: tasks[index].text,
                      isDone: tasks[index].isDone,
                      isEditable: _addingTasks,
                      onCheckboxChanged: (newValue) => onCheckboxChanged(index, newValue),
                      onImageChanged: (newImage) => onImageChanged(index, newImage),
                      onDelete: () => onDeleteTask(index),
                      onTextChanged: (newText) => onTextChanged(index, newText),
                      isHighlighted: tasks[index].isHighlighted,
                      showCancelIcon: tasks[index].showCancelIcon,
                      onCancel: () => cancelTask(index),
                      showCancelText: tasks[index].showCancelText,
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
                            margin: const EdgeInsets.only(right: 8.0),
                            height: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              boxShadow: [
                                const BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0, 0),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: TextField(
                                controller: _taskController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter a Task',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 18)
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Add some space between text field and buttons
                        ElevatedButton(
                          onPressed: () {
                            _addNewTask(_taskController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(50, 80),
                            elevation: 10,
                          ),
                          child: const Text(
                            '+',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // Add some space between text field and buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_selectedImagePath != null)
                          Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.only(left: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(File(_selectedImagePath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {
                            _pickImage(); // Replace _pickImage with your image picking logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(120, 50),
                            elevation: 10,
                          ),
                          child: const Text(
                            'Add Image',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _toggleTaskInput,
                          child: const Text(
                              'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            elevation: 4.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Add some space between buttons
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _toggleTaskInput,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 50),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: HttpHeaders.rangeHeader),
                        ),
                        child: const Text('Add Tasks'),
                      ),
                      const SizedBox(width: 15,),
                      ElevatedButton(
                        onPressed: _toggleAddingTasks,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(150, 50),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Done'),
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
                duration: const Duration(seconds: 1),
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
                      minimumSize: const Size(140, 40),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Edit Schedule'),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: _clearAllTasks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 40),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Clear Schedule'),
                  ),
                ],
              ),
            ),
          )
              : const SizedBox(),
          if (_editOngoingSchedule)
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: ongoingScheduleUpdateSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(150, 40),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Submit'),
              ),
            ),
        ],
      ),
    );
  }

  void _updateTitle(String newTitle) {
    setState(() {
      _titleController.text = newTitle;
      _isEditingTitle = false;
    });
    _databaseHelper.updateAppBarData(_appBarImagePath, newTitle);
  }

  AppBar _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple], // Define your gradient colors here
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          if (!_addingTasks) {
            _showEditConfirmationDialog();
          }
        },
      ),
      title: _isEditingTitle && _addingTasks
          ? Center(
        child: TextField(
          controller: _titleController,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Edit title',
          ),
          onSubmitted: (newTitle) {
            _updateTitle(newTitle);
          },
        ),
      )
          : GestureDetector(
        onTap: () {
          if (_addingTasks) {
            setState(() {
              _isEditingTitle = true;
            });
          }
        },
        child: Center(
          child: Text(
            _titleController.text,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize:22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      actions: [
        const SizedBox(width: 10),
        if (_appBarImagePath.isNotEmpty)
          GestureDetector(
            onTap: _showImageOptionsDialog,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(_appBarImagePath),
                fit: BoxFit.cover,
                width: 50, height: 50,
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(Icons.add_photo_alternate_outlined, size: 30, color: Colors.grey),
            onPressed: _pickAppBarImage,
          ),
      ],
    );
  }

}
