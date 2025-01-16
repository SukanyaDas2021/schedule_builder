import 'package:flutter/material.dart';
import 'task.dart'; // Assuming you have the Task model from previous code
import 'taskitem.dart'; // Assuming you have TaskItem widget for displaying tasks

class TaskScreen extends StatelessWidget {
  // Sample data for tasks (replace with your actual task data fetching logic)
  final List<Task> tasks = [
    Task(image: '', text: 'Task 1', isDone: false),
    Task(image: '', text: 'Task 2', isDone: true),
    // Add more tasks here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskItem(
            image: task.image,
            text: task.text,
            isDone: task.isDone,
            onCheckboxChanged: (bool? value) {
              // Handle task checkbox toggle
            },
            onImageChanged: (String newImage) {
              // Handle image change for the task
            },
            onDelete: () {
              // Handle task deletion
            },
            onTextChanged: (String newText) {
              // Handle text change for the task
            },
            isHighlighted: false,
            isEditable: true,
            showCancelIcon: true,
            showCancelText: false,
            onCancel: () {
              // Handle task cancellation
            },
          );
        },
      ),
    );
  }
}
