import 'package:equatable/equatable.dart';
import 'package:sqflite_todo_app/models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// while loading
class TaskLoadingState extends TaskState {}

/// after loading tasks
class TaskLoadedState extends TaskState {
  final List<TaskModel> tasks;

  const TaskLoadedState(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

/// on error while loading tasks
class TaskLoadErrorState extends TaskState {
  final String errorMessage;

  const TaskLoadErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
