import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_todo_app/models/task_model.dart';
import 'package:sqflite_todo_app/services/database_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(floatingActionButton: _addTaskButton(), body: _taskList());
  }

  @override
  void initState() {
    super.initState();
    _databaseServices.getAllTasks();
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: addTaskDialog,
      child: const Icon(Icons.add),
    );
  }

  void addTaskDialog() async {
    _focusNode.requestFocus();
    String? taskContent;
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add task"),
        content: StatefulBuilder(builder: (context, state) {
          void onPressed() async {
            if (taskContent != null && taskContent != '') {
              state(() {
                isLoading = true;
              });
              await _databaseServices.addTask(taskContent ?? 'Empty0');
              state(() {
                isLoading = false;
              });
            } else {
              log("task not added, it is cancelled!");
            }
            Navigator.pop(context);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                onChanged: (value) {
                  taskContent = value;
                  state(() {});
                },
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                onSubmitted: (value) => onPressed(),
              ),
              MaterialButton(
                onPressed: onPressed,
                color: Theme.of(context).primaryColor,
                child: Text(taskContent == null || taskContent!.isEmpty
                    ? "Cancel"
                    : isLoading
                        ? 'Adding...'
                        : "Done"),
              ),
            ],
          );
        }),
      ),
    );
    setState(() {});
  }

  Widget _taskList() {
    return Center(
      child: FutureBuilder(
        future: _databaseServices.getAllTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text("No data found in db!");
          }
          if (snapshot.hasError) {
            return Text("Error while getting data ${snapshot.error}");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CupertinoActivityIndicator();
          }
          List<TaskModel> taskList = snapshot.data ?? [];
          return ListView.builder(
            itemCount: taskList.length,
            itemBuilder: (context, index) {
              var item = taskList[index];
              return ListTile(
                title: Text(item.content),
                trailing: Checkbox(
                  value: item.status == 1,
                  onChanged: (value) {
                    _databaseServices.updateStatus(
                        value == true ? 1 : 0, item.id);
                    setState(() {});
                  },
                ),
                onLongPress: () {
                  _databaseServices.deleteTask(item.id);
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}
