# schedule_builder

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Task class (task.dart)

The Task class models a to-do item, encapsulating its image, text, completion status, highlighting, and display options for cancellation features. It includes methods to convert to and from a map for easy storage and retrieval in an SQLite database.

TaskItem class (task_item.dart)

The TaskItem class represents a visual component for a task, handling user interactions like marking as done, editing text, changing images, and deletion. It uses a stateful widget to manage UI updates and behavior based on task properties and user actions, including confirmation dialogs for deletions.

DatabaseHelper class (database_helper.dart)

The DatabaseHelper class manages SQLite database interactions for the app, including initializing the database, creating tables, and performing CRUD operations on tasks and app bar data. It ensures singleton instance access, facilitating data persistence and retrieval efficiently within the app.

Schedule Class (schedule.dart)

The Schedule class is a stateful widget that manages a user's task schedule. It interacts with DatabaseHelper to load, add, update, and delete tasks. The class allows users to input tasks, mark them as done, and handle images for tasks and app bar customization. It supports toggling task input visibility, editing ongoing schedules, and showing a thumbs-up animation when all tasks are completed. Users can also restart or clear the entire schedule. The UI includes a custom app bar with an optional image, task input field, and a list of tasks with various interactive options.
