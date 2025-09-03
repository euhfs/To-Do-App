import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/utils/colors.dart';
import 'package:todo_app/utils/todo.dart';
import 'package:todo_app/widgets/todo_tile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final storage = const FlutterSecureStorage();

class _HomePageState extends State<HomePage> {
  final List<ToDo> todosList = ToDo.todoList();
  final TextEditingController todoController = TextEditingController();

  List<ToDo> foundToDo = [];

  @override
  void initState() {
    super.initState();
    foundToDo = todosList;
    loadTodos();
  }

  // Key for secure storage
  final String storageKey = 'todos';

  // Save todos from secure storage
  Future<void> saveTodos() async {
    final todosJson = jsonEncode(
      todosList.map((todo) => todo.toJson()).toList(),
    );
    await storage.write(key: storageKey, value: todosJson);
  }

  // Load todos from secure storage
  Future<void> loadTodos() async {
    final todosJson = await storage.read(key: storageKey);
    if (todosJson != null && mounted) {
      final List decoded = jsonDecode(todosJson);
      setState(() {
        todosList
          ..clear()
          ..addAll(decoded.map((e) => ToDo.fromJson(e)));
        foundToDo = List.from(todosList);
      });
    }
  }

  // Function to handle todo item change (toggle done/undone)
  void _handleTodoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;

      // Remove the todo from the list
      todosList.removeWhere((item) => item.id == todo.id);

      if (todo.isDone) {
        // If done, add to the end (bottom)
        todosList.add(todo);
      } else {
        // If undone, add to the start (top)
        todosList.insert(0, todo);
      }

      foundToDo = List.from(todosList);
    });
    saveTodos();
  }

  // Function to update the title of the item
  void _updateTodoText(ToDo updatedTodo) {
    setState(() {
      final index = todosList.indexWhere((todo) => todo.id == updatedTodo.id);
      if (index != -1) {
        todosList[index].todoText = updatedTodo.todoText;
      }
      foundToDo = List.from(todosList);
    });
    saveTodos();
  }

  // Function to delete a todo item
  void _deleteItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
      foundToDo = List.from(todosList);
    });
    saveTodos();
  }

  // Function to add a new todo item
  void addItem(String toDo) {
    if (toDo.trim().isEmpty) return;
    setState(() {
      todosList.insert(
        0,
        ToDo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          todoText: toDo,
          isDone: false,
        ),
      );
      foundToDo = List.from(todosList);
    });
    saveTodos();
    todoController.clear();
  }

  // Function to filter todos based on search input
  void runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where(
            (item) => item.todoText.toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ),
          )
          .toList();
    }
    setState(() {
      foundToDo = results;
    });
  }

  // Dispose the controller to free up resources
  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // App Bar
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
        title: const Text(
          'To Do List',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: false,
      ),

      // Body
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) => runFilter(value),
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              enableSuggestions: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: filledColor,
                hintText: 'Search item...',
                hintStyle: TextStyle(fontSize: 24, color: hintColor),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 30,
                ),
              ),
            ),
          ),

          // To Do Items Title
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              'To Do Items',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.start,
            ),
          ),

          // Spacer
          const SizedBox(height: 24),

          // List of To Do Items
          Expanded(
            child: ListView.builder(
              itemCount: foundToDo.length,
              itemBuilder: (context, index) {
                final todoo = foundToDo[index];
                return TodoTile(
                  todo: todoo,
                  onToDoChanged: _handleTodoChange,
                  onDeleteItem: _deleteItem,
                  onTitleChanged: _updateTodoText,
                );
              },
            ),
          ),

          // Add New To Do Item Row
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(
                  // TextField for adding new tasks
                  child: Container(
                    margin: EdgeInsets.only(left: 7, right: 0),
                    child: TextField(
                      controller: todoController,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: filledColor,
                        hintText: 'Add a new task',
                        hintStyle: TextStyle(fontSize: 21, color: hintColor),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0),
                      ),
                    ),
                  ),
                ),

                // Spacer between TextField and Floating Action Button
                const SizedBox(width: 10),

                // Floating Action Button
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: floatingButton,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.black, size: 30),
                    onPressed: () {
                      if (todoController.text.isNotEmpty) {
                        addItem(todoController.text);
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Enter a task first',
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
