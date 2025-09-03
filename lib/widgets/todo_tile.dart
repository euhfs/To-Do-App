// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/todo.dart';

class TodoTile extends StatefulWidget {
  final ToDo todo;
  final onToDoChanged;
  final onDeleteItem;
  final onTitleChanged;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
    required this.onTitleChanged,
  });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  // Get the Item Title
  late String itemTitle = widget.todo.todoText;

  // Controller for Item Editing
  late TextEditingController editingController;

  @override
  void initState() {
    editingController = TextEditingController(text: itemTitle);

    super.initState();
  }

  @override
  void dispose() {
    editingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      // Tile
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: ListTile(
          onTap: () {
            widget.onToDoChanged(widget.todo);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          tileColor: tileColor,
          splashColor: Colors.transparent,

          // CheckBox
          leading: Icon(
            widget.todo.isDone
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: Colors.blueAccent,
          ),

          // Item Text
          title: Text(
            widget.todo.todoText,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              decoration: widget.todo.isDone
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),

          // Item Actions
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Button
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blueGrey, size: 32),
                tooltip: 'Edit Item',
                onPressed: () {
                  editingController.text = widget.todo.todoText;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: backgroundColor,

                        // Title
                        title: const Text(
                          'Edit Item',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // TextField to edit item
                        content: TextField(
                          enableSuggestions: false,
                          maxLines: null,
                          controller: editingController,

                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: filledColor,
                          ),
                        ),

                        // Actions
                        actions: [
                          // Cancel
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: actionItem, fontSize: 20),
                            ),
                          ),

                          // Confirm
                          TextButton(
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: actionItem, fontSize: 20),
                            ),
                            onPressed: () {
                              // Change The title
                              setState(() {
                                String newTitle = editingController.text;
                                widget.todo.todoText = newTitle;
                                widget.onTitleChanged(widget.todo);
                              });

                              // Close the dialog
                              Navigator.of(context).pop();

                              // Show a toast
                              Fluttertoast.showToast(
                                msg: 'Note Title Changed Successfully',
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              // Delete Button
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 32),
                tooltip: 'Delete Item',
                onPressed: () {
                  // Show confirmation Dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: backgroundColor,

                        // Title
                        title: const Text(
                          'Are you sure you want to delete this item?',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        actions: [
                          TextButton(
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.tealAccent,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text(
                              'Confirm',
                              style: TextStyle(fontSize: 22, color: Colors.red),
                            ),
                            onPressed: () {
                              widget.onDeleteItem(widget.todo.id);
                              Navigator.of(context).pop();

                              Fluttertoast.showToast(
                                msg: 'Item Deleted Successfully',
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
