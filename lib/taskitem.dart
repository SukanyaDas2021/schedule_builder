import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:schedule_builder/task.dart';
import 'package:image_picker/image_picker.dart';

class TaskItem extends StatefulWidget {
  final String image;
  final String text;
  final bool isDone;
  final ValueChanged<bool?> onCheckboxChanged;
  final ValueChanged<String> onImageChanged;
  final VoidCallback onDelete;
  final ValueChanged<String> onTextChanged;
  final bool isHighlighted;

  TaskItem({
    required this.image,
    required this.text,
    required this.isDone,
    required this.onCheckboxChanged,
    required this.onImageChanged,
    required this.onDelete,
    required this.onTextChanged,
    required this.isHighlighted,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  final TextEditingController _taskTextController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _taskTextController.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Task"),
              content: Text("Are you sure you want to delete this task?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Delete"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction){
        widget.onDelete();
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete, color: Colors.white,
        ),
      ),
      child: Container(
        height: 150.0,
        padding: const EdgeInsets.only(left: 4, right: 4), //fromLTRB(0,0,4,0),
        decoration: BoxDecoration(
          boxShadow: widget.isHighlighted
              ? [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.8), // Adjust the color and opacity for the glow effect
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 0), // Adjust the offset if needed
            ),
          ]
              : [],
          color: widget.isHighlighted ? Colors.green[50] : Colors.teal[50],
          //color: Colors.teal[50],
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: Colors.grey, // Border color
            width: 2.0, // Border width (you can adjust this value as needed)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    widget.onImageChanged(pickedFile.path);
                  }
                },
                child: widget.image.isNotEmpty
                    ? Image.file(
                  File(widget.image),
                  width: 130.0,
                  height: 130.0,
                  fit: BoxFit.cover,
                )
                : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.add_photo_alternate_outlined , size: 30, color: Colors.grey),
                )
              ),
            ),
            SizedBox(width: 15.0),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: isEditing
                      ? TextField(
                    controller: _taskTextController,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      decoration: widget.isDone ? TextDecoration.lineThrough : null,
                    ),
                    onSubmitted: (newText) {
                      widget.onTextChanged(newText);
                      setState(() {
                        isEditing = false;
                      });
                    },
                  )
                      : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        decoration: widget.isDone? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.0),
            Transform.scale(
              scale: 2,
              child: Checkbox(
                value: widget.isDone,
                onChanged: widget.onCheckboxChanged,
                checkColor: Colors.green[800],
                activeColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
