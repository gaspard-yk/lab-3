import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:provider/provider.dart';
import 'task.dart';
import 'db.dart';
// import 'package:todoey_flutter/screens/tasks_screen.dart';

void main() async {
  // init the hive
  await Hive.initFlutter();

  // open a box
  var box = await Hive.openBox('todo_db');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(primarySwatch: Colors.orange),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final _myBox = Hive.box('todo_db');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    // if this is the 1st time ever openin the app, then create default data
    if (_myBox.get("tasklist") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }

    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.tasklist[index][1] = !db.tasklist[index][1];
    });
    db.updateDataBase();
  }

  // save new task
  void saveNewTask() {
    setState(() {
      db.tasklist.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void saveTask(int index) {
    setState(() {
      db.tasklist[index][0] = _controller.text;
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      db.tasklist.removeAt(index);
    });
    db.updateDataBase();
  }

  // create a new task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void changeTask(int index) {
    _controller.text = db.tasklist[index][0];
    // Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: () => saveTask(index),
          onCancel: () {
            Navigator.of(context).pop();
            _controller.clear();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (db.tasklist.length > 0) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('TO DO'),
          // elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: Icon(Icons.add),
        ),
        body: Container(
          child: Column(children: <Widget>[
            MaterialButton(
              color: Colors.orange,
              child: Text("Sort"),
              onPressed: () {
                setState(() {
                  db.tasklist.sort(
                      (a, b) => a[1].toString().compareTo(b[1].toString()));
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: db.tasklist.length,
                itemBuilder: (context, index) {
                  return MaterialButton(
                    onPressed: () => changeTask(index),
                    child: ToDoTile(
                      taskName: db.tasklist[index][0],
                      taskCompleted: db.tasklist[index][1],
                      onChanged: (value) => checkBoxChanged(value, index),
                      index: index,
                      deleteFunction: (context) => deleteTask(index),
                      changetask: (index) => changeTask(index),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('TO DO'),
          // elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: Icon(Icons.add),
        ),
        body: Center(
          child: Text(
            "no task",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );
    }
  }
}
