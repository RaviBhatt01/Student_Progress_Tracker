import '../../../../core/errors/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  /// Fetches all tasks for the current user from the API.
  Future<({List<TaskEntity> tasks, Failure? failure})> getTasks();

  /// Creates a new task. Returns the created entity (with server-assigned ID).
  Future<({TaskEntity? task, Failure? failure})> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    String? category,
    DateTime? dueDate,
  });

  /// Updates an existing task.
  Future<({TaskEntity? task, Failure? failure})> updateTask(TaskEntity task);

  /// Deletes a task by ID.
  Future<({bool success, Failure? failure})> deleteTask(String id);
}
