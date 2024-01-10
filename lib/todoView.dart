import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'models/todo_model.dart';

class TodoView extends StatefulWidget {
  TodoModel todo;
  TodoView({Key? key, required this.todo}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _TodoViewState createState() => _TodoViewState(todo: todo);
}

class _TodoViewState extends State<TodoView> {
  TodoModel todo;
  _TodoViewState({required this.todo});
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (todo != null) {
      titleController.text = todo.title == null ? '' : todo.title!;
      descriptionController.text =
          todo.description == null ? '' : todo.description!;
      dueDateController.text = todo.dueDate == null
          ? '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
          : '${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}';
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Text(
          todo.title == null ? "Create" : todo.title!,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                    child: colorOverride(TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some title';
                    }
                    return null;
                  },
                  onChanged: (data) {
                    todo.title = data;
                  },
                  style: TextStyle(color: Colors.white),
                  decoration: new InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: "Title",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(color: Colors.white),
                    ),
                    //fillColor: Colors.green
                  ),
                  controller: titleController,
                ))),
                SizedBox(
                  height: 25,
                ),
                Container(
                  child: colorOverride(
                    TextFormField(
                      maxLines: 5,
                      onChanged: (data) {
                        todo.description = data;
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: new InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: "Description",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(color: Colors.white),
                        ),
                        //fillColor: Colors.green
                      ),
                      controller: descriptionController,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  child: colorOverride(
                    TextFormField(
                      readOnly: true,
                      keyboardAppearance: Brightness.dark,
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: todo.dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2025),
                        ).then((value) {
                          setState(() {
                            todo.dueDate = value;
                            dueDateController.text =
                                "${value!.day}/${value.month}/${value.year}";
                          });
                        });
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: new InputDecoration(
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: "Due Date",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(color: Colors.white),
                        ),
                      ),
                      controller: dueDateController,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Priority",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                      DropdownButton<TodoPriority>(
                        dropdownColor: Colors.black,
                        value: todo.priority,
                        items: [
                          TodoPriority.Low,
                          TodoPriority.Medium,
                          TodoPriority.High,
                        ]
                            .map((e) => DropdownMenuItem<TodoPriority>(
                                value: e,
                                child: Text(
                                  e.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            todo.priority = value as TodoPriority;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Category",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                      DropdownButton<Category>(
                        dropdownColor: Colors.black,
                        value: todo.category,
                        items: [
                          Category.Work,
                          Category.Personal,
                          Category.Shopping,
                          Category.Others
                        ]
                            .map((e) => DropdownMenuItem<Category>(
                                value: e,
                                child: Text(
                                  e.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            todo.category = value as Category;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                      DropdownButton<Status>(
                        dropdownColor: Colors.black,
                        value: todo.status,
                        items: [
                          Status.ToDo,
                          Status.InProgress,
                          Status.Done,
                        ]
                            .map((e) => DropdownMenuItem<Status>(
                                value: e,
                                child: Text(
                                  e.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                )))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            todo.status = value as Status;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                InkWell(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, todo);
                    }
                  },
                  child: Container(
                    height: 50,
                    width: width * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text("Save"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget colorOverride(Widget child) {
    return child;
  }
}
