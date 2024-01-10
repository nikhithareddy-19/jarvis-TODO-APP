import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/todo_model.dart';
import 'todoView.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoModel> todos = [];
  int highestId = 0;
  late List<TodoModel> lowPriorityTodos;
  late List<TodoModel> mediumPriorityTodos;
  late List<TodoModel> highPriorityTodos;

  late List<TodoModel> TodoStatusList;
  late List<TodoModel> InProgressTodoStatusList;
  late List<TodoModel> DoneTodoStatusList;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todos.json');
  }

  setupTodo() async {
    File file = await _localFile;

    // Check if the file exists
    if (await file.exists()) {
      // If the file exists, read it
      String stringTodo = await file.readAsString();
      List todoList = jsonDecode(stringTodo);
      for (var todo in todoList) {
        TodoModel model = TodoModel.fromJson(todo);
        setState(() {
          todos.add(TodoModel.fromJson(todo));
          if (model.id! > highestId) {
            highestId = model.id!;
          }
        });
      }

      todos.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    } else {
      // If the file doesn't exist, create it and initialize it with an empty list
      await file.writeAsString(jsonEncode([]));
    }
  }

  void saveTodo() async {
    File file = await _localFile;
    List items = todos.map((e) => e.toJson()).toList();
    file.writeAsString(jsonEncode(items));
    todos.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  @override
  void initState() {
    super.initState();
    setupTodo();
  }

  @override
  void dispose() {
    saveTodo();
    // TODO: implement dispose
    super.dispose();
  }

  String viewMode = 'duedate';
  int tabIndex = 0;

  Color appcolor = const Color.fromRGBO(58, 66, 86, 1.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appcolor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "JARVIS",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle selected option
              if (value == 'status') {
                // Sort by status
                setState(() {
                  TodoStatusList = todos // ToDo
                      .where((todo) => todo.status == Status.ToDo)
                      .toList();
                  InProgressTodoStatusList = todos // InProgress
                      .where((todo) => todo.status == Status.InProgress)
                      .toList();
                  DoneTodoStatusList = todos // Done
                      .where((todo) => todo.status == Status.Done)
                      .toList();
                });
              } else if (value == 'duedate') {
                // Sort by due date
                setState(() {
                  todos.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
                });
              } else if (value == 'priority') {
                // change mode to priority
                lowPriorityTodos = todos
                    .where((todo) => todo.priority == TodoPriority.Low)
                    .toList();
                mediumPriorityTodos = todos
                    .where((todo) => todo.priority == TodoPriority.Medium)
                    .toList();
                highPriorityTodos = todos
                    .where((todo) => todo.priority == TodoPriority.High)
                    .toList();
              }
              setState(() {
                viewMode = value;
              });
            },
            initialValue: 'dueDate',
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'status',
                child: Text('Sort by Status'),
              ),
              const PopupMenuItem<String>(
                value: 'duedate',
                child: Text('Sort by Due Date'),
              ),
              const PopupMenuItem<String>(
                value: 'priority',
                child: Text('Sort by Priority'),
              ),
            ],
            icon: const Icon(
              Icons.sort,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: viewMode == 'duedate'
          ? ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: todos.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    elevation: 8.0,
                    margin: new EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: const Color.fromRGBO(64, 75, 96, .9),
                      ),
                      child: InkWell(
                        onTap: () async {
                          TodoModel t = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TodoView(todo: todos[index])));
                          if (t != null) {
                            setState(() {
                              todos[index] = t;
                            });
                            saveTodo();
                          }
                        },
                        child: makeListTile(todos[index], index),
                      ),
                    ));
              })
          : viewMode == 'status' // Status
              ? (tabIndex == 0
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: TodoStatusList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            elevation: 8.0,
                            margin: new EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 6.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: const Color.fromRGBO(64, 75, 96, .9),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  TodoModel t = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TodoView(
                                              todo: TodoStatusList[index])));
                                  if (t != null) {
                                    setState(() {
                                      todos[todos
                                          .indexOf(TodoStatusList[index])] = t;
                                    });
                                    saveTodo();
                                  }
                                },
                                child:
                                    makeListTile(TodoStatusList[index], index),
                              ),
                            ));
                      })
                  : tabIndex == 1
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: InProgressTodoStatusList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                elevation: 8.0,
                                margin: new EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: const Color.fromRGBO(64, 75, 96, .9),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      TodoModel t = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => TodoView(
                                                  todo:
                                                      InProgressTodoStatusList[
                                                          index])));
                                      if (t != null) {
                                        setState(() {
                                          todos[todos.indexOf(
                                              InProgressTodoStatusList[
                                                  index])] = t;
                                        });
                                        saveTodo();
                                      }
                                    },
                                    child: makeListTile(
                                        InProgressTodoStatusList[index], index),
                                  ),
                                ));
                          })
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: DoneTodoStatusList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                elevation: 8.0,
                                margin: new EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: const Color.fromRGBO(64, 75, 96, .9),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      TodoModel t = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => TodoView(
                                                  todo: DoneTodoStatusList[
                                                      index])));
                                      if (t != null) {
                                        setState(() {
                                          todos[todos.indexOf(
                                              DoneTodoStatusList[index])] = t;
                                        });
                                        saveTodo();
                                      }
                                    },
                                    child: makeListTile(
                                        DoneTodoStatusList[index], index),
                                  ),
                                ));
                          }))
              : (tabIndex == 0 // Priority
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: lowPriorityTodos.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            elevation: 8.0,
                            margin: new EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 6.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: const Color.fromRGBO(64, 75, 96, .9),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  TodoModel t = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TodoView(
                                              todo: lowPriorityTodos[index])));
                                  if (t != null) {
                                    setState(() {
                                      todos[todos.indexOf(
                                          lowPriorityTodos[index])] = t;
                                    });
                                    saveTodo();
                                  }
                                },
                                child: makeListTile(
                                    lowPriorityTodos[index], index),
                              ),
                            ));
                      })
                  : tabIndex == 1
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: mediumPriorityTodos.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                elevation: 8.0,
                                margin: new EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: const Color.fromRGBO(64, 75, 96, .9),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      TodoModel t = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => TodoView(
                                                  todo: mediumPriorityTodos[
                                                      index])));
                                      if (t != null) {
                                        setState(() {
                                          todos[todos.indexOf(
                                              mediumPriorityTodos[index])] = t;
                                        });
                                        saveTodo();
                                      }
                                    },
                                    child: makeListTile(
                                        mediumPriorityTodos[index], index),
                                  ),
                                ));
                          })
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: highPriorityTodos.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                elevation: 8.0,
                                margin: new EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: const Color.fromRGBO(64, 75, 96, .9),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      TodoModel t = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => TodoView(
                                                  todo: highPriorityTodos[
                                                      index])));
                                      if (t != null) {
                                        setState(() {
                                          todos[todos.indexOf(
                                              highPriorityTodos[index])] = t;
                                        });
                                        saveTodo();
                                      }
                                    },
                                    child: makeListTile(
                                        highPriorityTodos[index], index),
                                  ),
                                ));
                          })),
      bottomNavigationBar: (viewMode == 'status' || viewMode == 'priority')
          ? BottomNavigationBar(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              currentIndex: tabIndex,
              unselectedLabelStyle: TextStyle(color: Colors.white60),
              selectedLabelStyle: TextStyle(
                color: Colors.white,
              ),
              onTap: (value) {
                setState(() {
                  tabIndex = value;
                });
              },
              items: [
                  BottomNavigationBarItem(
                      icon: viewMode == 'status'
                          ? Icon(
                              Icons.list,
                              color: Colors.black,
                            )
                          : Text(
                              "Low",
                              style: TextStyle(color: Colors.black),
                            ),
                      label: viewMode != 'status' ? '' : 'To-Do'),
                  BottomNavigationBarItem(
                      icon: viewMode == 'status'
                          ? Icon(
                              Icons.stop_circle_sharp,
                              color: Colors.black,
                            )
                          : Text(
                              "Medium",
                              style: TextStyle(color: Colors.black),
                            ),
                      label: viewMode != 'status' ? '' : 'In Progress'),
                  BottomNavigationBarItem(
                      icon: viewMode == 'status'
                          ? Icon(
                              Icons.done,
                              color: Colors.black,
                            )
                          : Text(
                              "High",
                              style: TextStyle(color: Colors.black),
                            ),
                      label: viewMode != 'status' ? '' : 'Done'),
                ])
          : null,
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.black12,
        onPressed: () {
          addTodo();
        },
      ),
    );
  }

  addTodo() async {
    highestId++;
    TodoModel t = TodoModel(
      title: null,
      description: null,
      status: viewMode == 'status'
          ? tabIndex == 0
              ? Status.ToDo
              : tabIndex == 1
                  ? Status.InProgress
                  : Status.Done
          : Status.ToDo,
      category: Category.Work,
      priority: viewMode == 'priority'
          ? tabIndex == 0
              ? TodoPriority.Low
              : tabIndex == 1
                  ? TodoPriority.Medium
                  : TodoPriority.High
          : TodoPriority.Low,
      dueDate: DateTime.now(),
      id: highestId,
    );
    TodoModel returnTodo = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TodoView(todo: t)));
    if (returnTodo != null) {
      setState(() {
        todos.add(returnTodo);
      });
      saveTodo();
    }
  }

  makeListTile(TodoModel todo, index) {
    List weekDay = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: const EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24))),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              todo.title!,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            todo.status == Status.Done
                ? Icon(Icons.check_circle, color: Colors.green)
                : todo.status == Status.InProgress
                    ? Icon(
                        Icons.stop_circle_sharp,
                        color: Colors.orange,
                      )
                    : Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      )
          ],
        ),
        subtitle: Wrap(
          children: <Widget>[
            Text(todo.description == null ? '' : todo.description!,
                overflow: TextOverflow.clip,
                maxLines: 1,
                style: const TextStyle(color: Colors.white)),
            Text(
                "${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year} - ${weekDay[todo.dueDate!.weekday]} ",
                overflow: TextOverflow.clip,
                maxLines: 1,
                style: const TextStyle(color: Colors.white))
          ],
        ),
        trailing: InkWell(
            onTap: () {
              delete(todo);
            },
            child: const Icon(Icons.delete, color: Colors.white, size: 30.0)));
  }

  delete(TodoModel todo) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Alert"),
              content: const Text("Are you sure to delete"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text("No")),
                TextButton(
                    onPressed: () {
                      setState(() {
                        todos.remove(todo);
                      });
                      Navigator.pop(ctx);
                      saveTodo();
                    },
                    child: const Text("Yes"))
              ],
            ));
  }
}
