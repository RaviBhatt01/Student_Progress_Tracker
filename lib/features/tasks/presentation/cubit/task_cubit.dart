import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repository;

  TaskCubit(this._repository) : super(const TaskState.initial());

  // --- Internal helpers ---

  List<TaskEntity> get _allTasks => switch (state) {
    TaskLoaded(:final allTasks) => allTasks,
    TaskMutating(:final allTasks) => allTasks,
    TaskError(:final allTasks) => allTasks,
    _ => [],
  };

  TaskFilter get _currentFilter => switch (state) {
    TaskLoaded(:final filter) => filter,
    TaskMutating(:final filter) => filter,
    TaskError(:final filter) => filter,
    _ => const TaskFilter(),
  };

/// Public getter used by the filter sheet to read current active filter
  TaskFilter get currentFilter => _currentFilter;

  void _emitLoaded(List<TaskEntity> allTasks, {TaskFilter? filter}) {
    final activeFilter = filter ?? _currentFilter;
    emit(
      TaskState.loaded(
        tasks: activeFilter.apply(allTasks),
        allTasks: allTasks,
        filter: activeFilter,
      ),
    );
  }

  void _emitMutating(List<TaskEntity> allTasks, {TaskFilter? filter}) {
    final activeFilter = filter ?? _currentFilter;
    emit(
      TaskState.mutating(
        tasks: activeFilter.apply(allTasks),
        allTasks: allTasks,
        filter: activeFilter,
      ),
    );
  }

  void _emitError(String message, List<TaskEntity> allTasks) {
    emit(
      TaskState.error(
        message: message,
        tasks: _currentFilter.apply(allTasks),
        allTasks: allTasks,
        filter: _currentFilter,
      ),
    );
  }

  // --- Public API ---

  Future<void> loadTasks() async {
    emit(const TaskState.loading());
    final result = await _repository.getTasks();
    if (result.failure != null) {
      _emitError(result.failure!.message, []);
    } else {
      _emitLoaded(result.tasks);
    }
  }

  void applyFilter(TaskFilter filter) => _emitLoaded(_allTasks, filter: filter);

  void clearFilter() => _emitLoaded(_allTasks, filter: const TaskFilter());

  Future<void> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    String? category,
    DateTime? dueDate,
  }) async {
    _emitMutating(_allTasks);
    final result = await _repository.createTask(
      title: title,
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
    );
    if (result.failure != null) {
      _emitError(result.failure!.message, _allTasks);
    } else {
      _emitLoaded([..._allTasks, result.task!]);
    }
  }

  Future<void> updateTask(TaskEntity updated) async {
    _emitMutating(_allTasks);
    final result = await _repository.updateTask(updated);
    if (result.failure != null) {
      _emitError(result.failure!.message, _allTasks);
    } else {
      final updatedAll = _allTasks
          .map((t) => t.id == result.task!.id ? result.task! : t)
          .toList();
      _emitLoaded(updatedAll);
    }
  }

  Future<void> toggleTaskStatus(TaskEntity task) async {
    final nextStatus = switch (task.status) {
      TaskStatus.pending => TaskStatus.inProgress,
      TaskStatus.inProgress => TaskStatus.completed,
      TaskStatus.completed => TaskStatus.pending,
    };
    await updateTask(task.copyWith(status: nextStatus));
  }

  Future<void> deleteTask(String id) async {
    _emitMutating(_allTasks);
    final result = await _repository.deleteTask(id);
    if (result.failure != null) {
      _emitError(result.failure!.message, _allTasks);
    } else {
      _emitLoaded(_allTasks.where((t) => t.id != id).toList());
    }
  }

  List<String> get availableCategories =>
      _allTasks.map((t) => t.category).whereType<String>().toSet().toList()
        ..sort();
}
