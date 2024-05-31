import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Fetch all tasks
class FetchTasks extends TaskEvent {}

/// Add task in task list
class AddTask extends TaskEvent {
  final String content;

  AddTask(this.content);

  @override
  List<Object?> get props => [content];
}

/// Delete task from task list
class DeleteTask extends TaskEvent {
  final int id;

  DeleteTask(this.id);

  @override
  List<Object?> get props => [id];
}

/// update task's status
class UpdateTaskStatus extends TaskEvent {
  final int id, status;

  UpdateTaskStatus(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}
