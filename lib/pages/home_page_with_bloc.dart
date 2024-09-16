import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_todo_app/bloc/task_bloc.dart';
import 'package:sqflite_todo_app/bloc/task_event.dart';
import 'package:sqflite_todo_app/bloc/task_state.dart';
import 'package:sqflite_todo_app/services/database_services.dart';

class HomePageWithBloc extends StatelessWidget {
  const HomePageWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseServices databaseServices = DatabaseServices.instance;

    return BlocProvider(
      create: (context) => TaskBloc(databaseServices)..add(FetchTasks()),
      child: Builder(builder: (context) {
        final taskBloc = context.read<TaskBloc>();
        return Scaffold(
          appBar: AppBar(
              title: const Text("Home page with bloc"), centerTitle: true),
          floatingActionButton: _addTaskButton(context, taskBloc),
          body: _taskList(),
        );
      }),
    );
  }

  Widget _addTaskButton(BuildContext context, TaskBloc taskBloc) {
    return FloatingActionButton(
      onPressed: () => addTaskDialog(context, taskBloc),
      child: const Icon(Icons.add),
    );
  }

  void addTaskDialog(BuildContext context, TaskBloc taskBloc) async {
    String? taskContent;
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add task"),
        content: StatefulBuilder(builder: (context, state) {
          void onPressed() {
            if (taskContent != null && taskContent != '') {
              state(() {
                isLoading = true;
              });
              taskBloc.add(AddTask(taskContent ?? 'Empty0'));
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
  }

  Widget _taskList() {
    return Center(
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadingState) {
            return const CupertinoActivityIndicator();
          } else if (state is TaskLoadedState) {
            if (state.tasks.isEmpty) {
              return const Text("No data found in db!");
            } else {
              final taskList = state.tasks;
              return ListView.builder(
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  var item = taskList[index];
                  return ListTile(
                    title: Text(item.content),
                    trailing: Checkbox(
                      value: item.status == 1,
                      onChanged: (value) => context.read<TaskBloc>().add(
                          UpdateTaskStatus(item.id, value == true ? 1 : 0)),
                    ),
                    onLongPress: () =>
                        context.read<TaskBloc>().add(DeleteTask(item.id)),
                  );
                },
              );
            }
          } else if (state is TaskLoadErrorState) {
            return Text("Error while getting data ${state.errorMessage}");
          } else {
            return Text("Unknown state: $state");
          }
        },
      ),
    );
  }
}
