import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:schedule_builder/taskitem.dart';
import 'package:schedule_builder/task.dart';
import 'package:schedule_builder/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schedule_builder/schedulemodel.dart';
import 'package:schedule_builder/schedulescreen.dart';
import 'dart:io';

class Schedule extends StatefulWidget {
  final ScheduleModel schedule;

  Schedule({required this.schedule});

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String _appBarImagePath = '';
  List<Task> tasks = [];
  bool addingTasks = true;
  bool checkboxClickable = false;
  bool showTaskInput = false;
  bool _editOngoingSchedule = false;
  int highlightedTaskIndex = -1;

  final _taskController = TextEditingController();

  // AppBar title state
  bool _isEditingTitle = false;
  final TextEditingController _titleController = TextEditingController(text: "My Schedule");

  bool _showThumbsUp = false;
  String? _selectedImagePath;

  void _toggleThumbsUp() {
    setState(() {
      _showThumbsUp = !_showThumbsUp;
      checkboxClickable = false;
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
    addingTasks = widget.schedule.addingTasks;
    checkboxClickable = widget.schedule.checkboxClickable;
    showTaskInput = widget.schedule.showTaskInput;
    highlightedTaskIndex = widget.schedule.highlightedTaskIndex;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await _databaseHelper.getTasks(widget.schedule.id);
    final appBarData = await _databaseHelper.getAppBarData(widget.schedule.id);
    setState(() {
      tasks = loadedTasks;
      _appBarImagePath = appBarData['imagePath']!;
      _titleController.text = appBarData['title']!;
      if (tasks.isNotEmpty) {
        highlightedTaskIndex = tasks.indexWhere((task) => task.isHighlighted);
        checkboxClickable = !addingTasks;
        if (highlightedTaskIndex != -1)
          _databaseHelper.updateTask(tasks[highlightedTaskIndex], widget.schedule.id);
      }
      //_databaseHelper.updateSchedule(widget.schedule);
      //_saveScheduleChanges(widget.schedule);
      _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'highlightedTaskIndex', highlightedTaskIndex);
      _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'checkboxClickable', checkboxClickable);

    });
  }

  void onCheckboxChanged(int index, bool? newValue) {
    if (!checkboxClickable) return;
    setState(() {
      tasks[index].isDone = newValue ?? false;
      if (newValue ?? false) {
        int nextIndex = index + 1;
        while (nextIndex < tasks.length && tasks[nextIndex].showCancelText) {
          nextIndex++;
        }
        highlightedTaskIndex = (nextIndex < tasks.length) ? nextIndex : -1;
        if (highlightedTaskIndex > -1) {
          tasks[highlightedTaskIndex].isHighlighted = true;
          tasks[index].isHighlighted = false;
          _databaseHelper.updateTask(tasks[index], widget.schedule.id);
          _databaseHelper.updateTask(tasks[highlightedTaskIndex], widget.schedule.id);
        }
        if (index == tasks.length - 1 || (nextIndex >= tasks.length && tasks[index].isDone)) {
          tasks[index].isHighlighted = false;
          _databaseHelper.updateTask(tasks[index], widget.schedule.id);
        }
        _databaseHelper.updateTask(tasks[index], widget.schedule.id);

      }
      if (_allTasksDone()) {
        _toggleThumbsUp();
      }
      //_databaseHelper.updateSchedule(widget.schedule);
      //_saveScheduleChanges(widget.schedule);
      _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'highlightedTaskIndex', highlightedTaskIndex);

    });
  }

  void _addNewTask(String taskText) {
    if (!addingTasks) return;
    String trimmedText = taskText.trim();
    if (trimmedText.isNotEmpty) {
      final newTask = Task(image: _selectedImagePath ?? '', text: taskText, isDone: false);
      setState(() {
        tasks.add(newTask);
        //int newIndex = tasks.length - 1;
        _taskController.clear();
        showTaskInput = false;  // Hide the input after adding a task
        _selectedImagePath = null;
        if (highlightedTaskIndex == -1) {
          highlightedTaskIndex = 0;
        }
        //_pickImage();
      });
      _databaseHelper.insertTask(newTask, widget.schedule.id);
      //_databaseHelper.updateSchedule(widget.schedule);
      //_saveScheduleChanges(widget.schedule);
      _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'highlightedTaskIndex', highlightedTaskIndex);
      _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'showTaskInput', showTaskInput);
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
                  addingTasks = false;
                  checkboxClickable = true;
                  tasks[0].isHighlighted = true;
                  showTaskInput = false;
                });
                _databaseHelper.updateTask(tasks[0], widget.schedule.id);
                Navigator.pop(context); // Close the dialog
                //_databaseHelper.updateSchedule(widget.schedule);
                _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'showTaskInput', showTaskInput);
                _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'addingTasks', addingTasks);
                _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'checkboxClickable', checkboxClickable);
                //_saveScheduleChanges(widget.schedule);
                _databaseHelper.updateAppBarData(_appBarImagePath, _titleController.text, widget.schedule.id);
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
    _databaseHelper.updateTask(tasks[index], widget.schedule.id);
  }

  void onDeleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _databaseHelper.deleteAllTasks(widget.schedule.id); // Clear all tasks and reinsert remaining ones
    for (var task in tasks) {
      _databaseHelper.insertTask(task, widget.schedule.id);
    }
  }

  void onTextChanged(int index, String newText) {
    setState(() {
      tasks[index].text = newText;
    });
    _databaseHelper.updateTask(tasks[index], widget.schedule.id);
  }

  void _restartSchedule() {
    setState(() {
      tasks.forEach((task) {
        task.isDone = false;
        task.isHighlighted = false;
        task.showCancelText = false;
      });
      addingTasks = true;
      checkboxClickable = false;
      // Highlight the first task item
      //if (tasks.isNotEmpty) {
      //  tasks[0].isHighlighted = true;
      //}
    });
    _databaseHelper.deleteAllTasks(widget.schedule.id);
    for (var task in tasks) {
      _databaseHelper.insertTask(task, widget.schedule.id);
    }
    //_databaseHelper.updateSchedule(widget.schedule);
    //_saveScheduleChanges(widget.schedule);
    _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'addingTasks', addingTasks);
    _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'checkboxClickable', checkboxClickable);
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
                  highlightedTaskIndex = -1;
                  addingTasks = true;
                  checkboxClickable = false;
                });
                _databaseHelper.deleteAllTasks(widget.schedule.id);
                //_databaseHelper.updateSchedule(widget.schedule);
                //_saveScheduleChanges(widget.schedule);
                _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'addingTasks', addingTasks);
                _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'checkboxClickable', checkboxClickable);
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
      _databaseHelper.updateAppBarImage(_appBarImagePath,widget.schedule.id);
    }
  }

  void _toggleTaskInput() {
    print('modifying showTaskInput from {$showTaskInput}...');
    setState(() {
      showTaskInput = !showTaskInput;
      _selectedImagePath = null;
      _taskController.text = '';
    });
    //_databaseHelper.updateSchedule(widget.schedule);
    //_saveScheduleChanges(widget.schedule);
    _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'showTaskInput', showTaskInput);
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
                  checkboxClickable = false;
                });
                _showCancelIconsForUncompletedTasks();
                Navigator.pop(context);
                //_databaseHelper.updateSchedule(widget.schedule);
                //_saveScheduleChanges(widget.schedule);
                _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'checkboxClickable', checkboxClickable);
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
          _databaseHelper.updateTask(task, widget.schedule.id);
        }
      }
    });
    //_databaseHelper.updateSchedule(widget.schedule);
    _saveScheduleChanges(widget.schedule);
  }

  void cancelTask(index) {
    setState(() {
      checkboxClickable = false;
      tasks[index].showCancelIcon = false;
      tasks[index].isHighlighted = false;
      tasks[index].showCancelText = true;
      tasks[index].isDone = true;
    });
    _databaseHelper.updateTask(tasks[index], widget.schedule.id);
    //_databaseHelper.updateSchedule(widget.schedule);
    _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'checkboxClickable', checkboxClickable);
  }

  void ongoingScheduleUpdateSubmit() {
    setState(() {
      checkboxClickable = true;
      _editOngoingSchedule = false;
      tasks.forEach((task) {
        task.showCancelIcon = false;
        if (task.showCancelText) {
          task.isHighlighted = false;
        }
        _databaseHelper.updateTask(task, widget.schedule.id);
      });
      _databaseHelper.updateSchedule(widget.schedule);
      _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'checkboxClickable', checkboxClickable);
    });
  }

  void _saveScheduleChanges(ScheduleModel updatedSchedule) {
    _databaseHelper.updateSchedule(updatedSchedule).then((_) {
      print('Schedule changes saved');
    }).catchError((error) {
      print('Failed to save schedule changes: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor:
      addingTasks ? Colors.indigo[50] : Colors.white,
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
                padding: EdgeInsets.fromLTRB(2, 2, 2, addingTasks ? 120 : 5),
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TaskItem(
                        image: tasks[index].image,
                        text: tasks[index].text,
                        isDone: tasks[index].isDone,
                        isEditable: addingTasks,
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
            if (showTaskInput)
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
            if (!showTaskInput)
              Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: addingTasks,
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
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(130, 50),
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
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _restartSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(125, 40),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Edit Schedule'),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: _clearAllTasks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
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
            Positioned(
              bottom: 10.0,
              left: 5.0,
              child: FloatingActionButton(
                backgroundColor: Colors.purple[50],
                focusColor: Colors.lightBlueAccent,
                onPressed: () {
                  //_databaseHelper.updateSchedule(widget.schedule);
                  _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'addingTasks', addingTasks);
                  _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'checkboxClickable', checkboxClickable);
                  _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'showTaskInput', showTaskInput);
                  _databaseHelper.updateScheduleColumnValue(widget.schedule.id, 'highlightedTaskIndex', highlightedTaskIndex);
                  //_saveScheduleChanges(widget.schedule);

                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
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
    _databaseHelper.updateAppBarData(_appBarImagePath, newTitle, widget.schedule.id);
  }

  PreferredSize _buildAppBar() {
    double appBarHeight = MediaQuery.of(context).size.height * 0.08; //

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
        leading:
        IconButton(
          alignment: Alignment.centerLeft,
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            if (!addingTasks && !tasks.every((task) => task.isDone)) {
              _showEditConfirmationDialog();
            }
          },
        ),
        title: _isEditingTitle && addingTasks
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
            if (addingTasks) {
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
      ),
    );
  }

}
