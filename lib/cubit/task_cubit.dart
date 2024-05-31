import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_todo_app/bloc/task_state.dart';
import 'package:sqflite_todo_app/services/database_services.dart';

class TaskCubit extends Cubit<TaskState> {
  final DatabaseServices _databaseServices;

  TaskCubit(this._databaseServices) : super(TaskLoadingState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final tasks = await _databaseServices.getAllTasks();
      emit(TaskLoadedState(tasks));
    } catch (e) {
      emit(TaskLoadErrorState(e.toString()));
    }
  }

  Future<void> addTask(String content) async {
    try {
      await _databaseServices.addTask(content);

      await loadTasks();
    } catch (e) {
      emit(TaskLoadErrorState(e.toString()));
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _databaseServices.deleteTask(id);
      await loadTasks();
    } catch (e) {
      emit(TaskLoadErrorState(e.toString()));
    }
  }

  Future<void> updateTaskStatus(int status, int id) async {
    try {
      await _databaseServices.updateStatus(status, id);
      await loadTasks();
    } catch (e) {
      emit(TaskLoadErrorState(e.toString()));
    }
  }
}
