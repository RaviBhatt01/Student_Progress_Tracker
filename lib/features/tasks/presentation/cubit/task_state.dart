import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';

part 'task_state.freezed.dart';

@freezed
sealed class TaskState with _$TaskState {
  const factory TaskState.initial() = TaskInitial;

  const factory TaskState.loading() = TaskLoading;

  /// Full list loaded — [tasks] is already filtered + sorted
  const factory TaskState.loaded({
    required List<TaskEntity> tasks,
    required List<TaskEntity> allTasks, // unfiltered, used by cubit internally
    required TaskFilter filter,
  }) = TaskLoaded;

  /// A create/update/delete is in progress — list stays visible
  const factory TaskState.mutating({
    required List<TaskEntity> tasks,
    required List<TaskEntity> allTasks,
    required TaskFilter filter,
  }) = TaskMutating;

  /// Any operation failed — list stays visible with last good data
  const factory TaskState.error({
    required String message,
    required List<TaskEntity> tasks,
    required List<TaskEntity> allTasks,
    required TaskFilter filter,
  }) = TaskError;
}
