import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import 'task_remote_datasource.dart';

class TaskMockDataSource implements TaskRemoteDataSource {
  static const _delay = Duration(milliseconds: 600);
  static const _uuid = Uuid();

  // In-memory task store — mutations are reflected immediately within the session
  final List<TaskModel> _tasks = [
    TaskModel(
      id: 'task-001',
      title: 'Complete Flutter assignment',
      description: 'Finish the state management section and submit by Friday.',
      priority: 'high',
      status: 'in_progress',
      category: 'University',
      dueDate: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      createdAt: DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    ),
    TaskModel(
      id: 'task-002',
      title: 'Read chapter 5 — Algorithms',
      description: 'Cover sorting and searching algorithms before the quiz.',
      priority: 'medium',
      status: 'pending',
      category: 'Study',
      dueDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      createdAt: DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
    ),
    TaskModel(
      id: 'task-003',
      title: 'Submit group project report',
      description: null,
      priority: 'high',
      status: 'pending',
      category: 'University',
      dueDate: DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(), // overdue
      createdAt: DateTime.now()
          .subtract(const Duration(days: 5))
          .toIso8601String(),
    ),
    TaskModel(
      id: 'task-004',
      title: 'Review lecture notes',
      description: 'Go over weeks 3–5 before the mid-term.',
      priority: 'low',
      status: 'completed',
      category: 'Study',
      dueDate: null,
      createdAt: DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
    ),
    TaskModel(
      id: 'task-005',
      title: 'Buy new notebook',
      description: null,
      priority: 'low',
      status: 'pending',
      category: 'Personal',
      dueDate: null,
      createdAt: DateTime.now()
          .subtract(const Duration(hours: 6))
          .toIso8601String(),
    ),
  ];

  @override
  Future<List<TaskModel>> getTasks() async {
    await Future.delayed(_delay);
    // Return a copy so callers can't accidentally mutate the store
    return List.unmodifiable(_tasks);
  }

  @override
  Future<TaskModel> createTask(Map<String, dynamic> body) async {
    await Future.delayed(_delay);

    final newTask = TaskModel(
      id: _uuid.v4(),
      title: body['title'] as String,
      description: body['description'] as String?,
      priority: body['priority'] as String? ?? 'medium',
      status: 'pending',
      category: body['category'] as String?,
      dueDate: body['due_date'] as String?,
      createdAt: DateTime.now().toIso8601String(),
    );

    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<TaskModel> updateTask(String id, Map<String, dynamic> body) async {
    await Future.delayed(_delay);

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw Exception('Task $id not found');

    final existing = _tasks[index];
    final updated = existing.copyWith(
      title: body['title'] as String? ?? existing.title,
      description: body['description'] as String? ?? existing.description,
      priority: body['priority'] as String? ?? existing.priority,
      status: body['status'] as String? ?? existing.status,
      category: body['category'] as String? ?? existing.category,
      dueDate: body['due_date'] as String? ?? existing.dueDate,
    );

    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask(String id) async {
    await Future.delayed(_delay);
    _tasks.removeWhere((t) => t.id == id);
  }
}
