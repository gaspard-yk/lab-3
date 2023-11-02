import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List tasklist = [];

  // reference our box
  final db = Hive.box('todo_db');

  // run this method if this is the 1st time ever opening this app
  void createInitialData() {
    tasklist = [
      ["task_1", false]
    ];
  }

  void loadData() {
    tasklist = db.get("tasklist");
  }

  // update the database
  void updateDataBase() {
    db.put("tasklist", tasklist);
  }
}
