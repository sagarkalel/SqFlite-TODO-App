import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_todo_app/bloc/task_event.dart';
import 'package:sqflite_todo_app/bloc/task_state.dart';
import 'package:sqflite_todo_app/services/database_services.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DatabaseServices _databaseServices;

  /// initial state
  TaskBloc(this._databaseServices) : super(TaskLoadingState()) {
    /// event on fetch task
    on<FetchTasks>((event, emit) async {
      emit(TaskLoadingState());
      try {
        // adding delay manually here to display loading state of bloc
        await Future.delayed(const Duration(seconds: 3));
        final tasks = await _databaseServices.getAllTasks();
        emit(TaskLoadedState(tasks));
      } catch (e) {
        emit(TaskLoadErrorState(e.toString()));
      }
    });

    /// event on Delete task
    on<DeleteTask>((event, emit) async {
      try {
        await _databaseServices.deleteTask(event.id);
        final tasks = await _databaseServices.getAllTasks();
        emit(TaskLoadedState(tasks));
      } catch (e) {
        emit(TaskLoadErrorState(e.toString()));
      }
    });

    /// event on Update task's status
    on<UpdateTaskStatus>((event, emit) async {
      try {
        await _databaseServices.updateStatus(event.status, event.id);
        final tasks = await _databaseServices.getAllTasks();
        emit(TaskLoadedState(tasks));
      } catch (e) {
        emit(TaskLoadErrorState(e.toString()));
      }
    });

    /// event on adding task
    on<AddTask>((event, emit) async {
      try {
        await _databaseServices.addTask(event.content);
        final tasks = await _databaseServices.getAllTasks();
        emit(TaskLoadedState(tasks));
      } catch (e) {
        emit(TaskLoadErrorState(e.toString()));
      }
    });
  }
}
