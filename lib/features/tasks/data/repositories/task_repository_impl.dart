import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;

  TaskRepositoryImpl({required TaskRemoteDataSource remote}) : _remote = remote;

  @override
  Future<({List<TaskEntity> tasks, Failure? failure})> getTasks() async {
    try {
      final models = await _remote.getTasks();
      return (tasks: models.map((m) => m.toEntity()).toList(), failure: null);
    } on DioException catch (e) {
      return (tasks: <TaskEntity>[], failure: dioExceptionToFailure(e));
    } catch (_) {
      return (
        tasks: <TaskEntity>[],
        failure: const ServerFailure('Failed to load tasks.'),
      );
    }
  }

  @override
  Future<({TaskEntity? task, Failure? failure})> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    String? category,
    DateTime? dueDate,
  }) async {
    try {
      // Build a temporary entity just to reuse the toJson mapper
      final tempEntity = TaskEntity(
        id: '',
        title: title,
        description: description,
        priority: priority,
        status: TaskStatus.pending,
        category: category,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );
      final model = await _remote.createTask(taskEntityToJson(tempEntity));
      return (task: model.toEntity(), failure: null);
    } on DioException catch (e) {
      return (task: null, failure: dioExceptionToFailure(e));
    } catch (_) {
      return (
        task: null,
        failure: const ServerFailure('Failed to create task.'),
      );
    }
  }

  @override
  Future<({TaskEntity? task, Failure? failure})> updateTask(
    TaskEntity task,
  ) async {
    try {
      final model = await _remote.updateTask(task.id, taskEntityToJson(task));
      return (task: model.toEntity(), failure: null);
    } on DioException catch (e) {
      return (task: null, failure: dioExceptionToFailure(e));
    } catch (_) {
      return (
        task: null,
        failure: const ServerFailure('Failed to update task.'),
      );
    }
  }

  @override
  Future<({bool success, Failure? failure})> deleteTask(String id) async {
    try {
      await _remote.deleteTask(id);
      return (success: true, failure: null);
    } on DioException catch (e) {
      return (success: false, failure: dioExceptionToFailure(e));
    } catch (_) {
      return (
        success: false,
        failure: const ServerFailure('Failed to delete task.'),
      );
    }
  }
}
